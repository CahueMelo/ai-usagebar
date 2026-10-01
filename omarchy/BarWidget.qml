import QtQuick
import Quickshell
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Quattro bar entry point. The popup is loaded separately so the object in
// the bar slot owns shell routing while Panel.qml remains focused on report
// collection and presentation.
BarWidget {
  id: root
  moduleName: "akitaonrails.ai-usagebar"

  readonly property var panelItem: panelLoader.item
  readonly property bool opened: panelItem ? panelItem.opened === true : false
  readonly property bool popoutSwitchClosing: panelItem
    ? panelItem.popoutSwitchClosing === true
    : false
  // The bar presses a slot's widget with no coordinates, so the button cannot
  // tell which chip was clicked. Each chip registers as its own click target
  // instead, and the bar presses the one under the pointer by geometry. It
  // scans targets last first, so the chips are re-registered behind the
  // button's whole-slot target whenever the row or the bar changes.
  function chipItems() {
    var items = []
    for (var i = 0; i < chipRepeater.count; i++) {
      var item = chipRepeater.itemAt(i)
      if (item) items.push(item)
    }
    return items
  }

  function syncChipTargets() {
    var host = root.bar
    if (!host || typeof host.registerClickTarget !== "function") return
    // Anything of ours that is not the button is a chip, current or rebuilt.
    var registered = host.clickTargets || []
    for (var i = 0; i < registered.length; i++)
      if (registered[i] !== button) host.unregisterClickTarget(registered[i])
    var chips = chipItems()
    // A lone chip, a vertical bar or an empty report keeps the button as the
    // only target, and its press toggles the panel the way it always did.
    if (chips.length <= 1) return
    for (var j = 0; j < chips.length; j++) host.registerClickTarget(chips[j])
  }

  function open() {
    if (panelItem) panelItem.open()
  }

  function close() {
    if (panelItem) panelItem.close()
  }

  function toggle() {
    if (panelItem) panelItem.toggle()
  }

  function closeForPopoutSwitch() {
    if (panelItem) panelItem.closeForPopoutSwitch()
  }

  function refresh() {
    if (panelItem) panelItem.refresh()
  }

  function nextEntry() {
    if (panelItem) panelItem.selectEntry(panelItem.entryIndex + 1)
  }

  function launchDashboard() {
    if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation ai-usagebar-tui")
    root.close()
  }

  function injectPanel() {
    var target = panelItem
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: {
    injectPanel()
    // The bar is injected after the widget completes, and the button's own
    // registration rides the same change; re-assert the chips once both are
    // done so the bar scans them ahead of the button.
    Qt.callLater(root.syncChipTargets)
  }
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: " "
    labelVisible: false
    hasVisualContent: true
    fontSize: Style.font.bodySmall
    active: root.panelItem ? root.panelItem.alarming : false
    tooltipText: root.panelItem ? root.panelItem.tooltipText() : "AI usage"
    horizontalMargin: 8.5
    // The row's outer chips carry the edge padding, so it is not added here.
    fixedWidth: root.bar && root.bar.vertical ? -1 : chipRow.implicitWidth

    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.launchDashboard()
      else if (buttonCode === Qt.MiddleButton) root.nextEntry()
      else root.toggle()
    }

    onWheelMoved: function(delta) {
      if (delta !== 0 && root.panelItem)
        root.panelItem.selectEntry(root.panelItem.entryIndex + (delta < 0 ? 1 : -1))
    }

    Row {
      id: chipRow
      anchors.centerIn: parent
      // Every chip carries the gaps beside it, so the row adds none of its own.
      spacing: 0
      visible: !(root.bar && root.bar.vertical)

      Repeater {
        id: chipRepeater
        model: root.panelItem ? root.panelItem.barChips : []
        // The model is rebuilt when the report changes, which replaces every
        // delegate and the click targets that point at them.
        onModelChanged: Qt.callLater(root.syncChipTargets)

        // The bar presses a slot's widget by geometry, so the registered target
        // is the chip's whole column of the slot rather than the glyph inside
        // it: a press on the padding above, below or beside the glyph would
        // otherwise reach the button and toggle whichever entry was already
        // selected. The column owns half of every gap beside it, split at the
        // midpoint with its neighbour, and the outer columns own the button's
        // padding at either end, which leaves the widget's width and each
        // chip's place in it exactly as the plain spacing and padding drew them.
        Item {
          id: chipHit
          readonly property var hitGaps: Model.chipHitGaps(index, chipRepeater.count, Style.space(10), Style.spaceReal(17) / 2)
          height: button.height
          width: chipContent.implicitWidth + hitGaps.left + hitGaps.right

          // One chip per provider, and the one the pointer is on is the one
          // the bar presses: left opens that provider's page, while the other
          // buttons keep their panel-wide meaning.
          function triggerPress(buttonCode) {
            if (buttonCode === Qt.RightButton) root.launchDashboard()
            else if (buttonCode === Qt.MiddleButton) root.nextEntry()
            else if (root.panelItem) root.panelItem.openEntry(modelData.id || "")
          }

          Row {
            id: chipContent
            x: chipHit.hitGaps.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(4)
            // While the panel is open, the chips it is not showing step back.
            opacity: root.opened && root.panelItem && modelData.id
              && modelData.id !== root.panelItem.selectedEntryId ? 0.45 : 1

            Behavior on opacity {
              NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
            }

            BrandMark {
              anchors.verticalCenter: parent.verticalCenter
              brand: modelData.brand || ""
              fallback: modelData.icon || "󰚩"
              foreground: modelData.alarming && button.useActiveColor
                ? button.activeColor
                : button.foreground
              fontFamily: button.fontFamily
              fontSize: button.fontSize
            }

            Text {
              visible: modelData.label !== ""
              anchors.verticalCenter: parent.verticalCenter
              textFormat: Text.PlainText
              text: modelData.label
              color: modelData.alarming && button.useActiveColor
                ? button.activeColor
                : button.foreground
              font.family: button.fontFamily
              font.pixelSize: button.fontSize
            }
          }
        }
      }
    }

    Text {
      visible: root.bar && root.bar.vertical
      anchors.centerIn: parent
      textFormat: Text.PlainText
      text: root.panelItem && root.panelItem.alarming ? "󰅙" : "󰚩"
      color: button.active && button.useActiveColor ? button.activeColor : button.foreground
      font.family: button.fontFamily
      font.pixelSize: button.fontSize
      rotation: button.textRotation
    }
  }
}
