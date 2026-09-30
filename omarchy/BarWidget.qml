import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

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

  // Quickshell window that hosts this bar slot (not the usage panel popup).
  readonly property var barWindow: button.QsWindow ? button.QsWindow.window : null

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
    var registered = host.clickTargets || []
    for (var i = 0; i < registered.length; i++)
      if (registered[i] !== button) host.unregisterClickTarget(registered[i])
    var chips = chipItems()
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

  function segmentColor(severity) {
    if (!severity) return button.foreground
    if (root.panelItem && typeof root.panelItem.severityColorOf === "function")
      return root.panelItem.severityColorOf(severity)
    return button.foreground
  }

  function escapeHtml(value) {
    return String(value || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
  }

  readonly property string tipPlain: {
    var rows = root.panelItem ? (root.panelItem.ragTooltipRows || []) : []
    if (rows && rows.length > 0) {
      var lines = []
      for (var i = 0; i < rows.length; i++) {
        var text = String((rows[i] && rows[i].text) || "").trim()
        if (text !== "") lines.push(text)
      }
      if (lines.length > 0) return lines.join("\n")
    }
    if (root.panelItem && root.panelItem.plainTooltipText)
      return root.panelItem.plainTooltipText
    return "AI usage"
  }

  readonly property string tipHtml: {
    if (root.panelItem && root.panelItem.colorCodeUsage === false) return ""
    var rows = root.panelItem ? (root.panelItem.ragTooltipRows || []) : []
    var _g = root.panelItem ? root.panelItem.hexGreen : ""
    var _y = root.panelItem ? root.panelItem.hexYellow : ""
    var _o = root.panelItem ? root.panelItem.hexOrange : ""
    var _r = root.panelItem ? root.panelItem.hexRed : ""
    var _ = [_g, _y, _o, _r]
    if (!rows || rows.length === 0) return ""
    var lines = []
    for (var i = 0; i < rows.length; i++) {
      var row = rows[i] || {}
      var body = root.escapeHtml(row.text || "")
      if (body === "") continue
      var hex = ""
      if (row.severity && root.panelItem && typeof root.panelItem.severityHexOf === "function")
        hex = String(root.panelItem.severityHexOf(row.severity) || "")
      if (hex !== "")
        lines.push("<span style=\"color:" + hex + "\">" + body + "</span>")
      else
        lines.push(body)
    }
    return lines.join("<br/>")
  }

  // Colored tip when we have per-line severity HTML and the bar window exists.
  // Independent of the usage panel popup (`opened`) for *hover*, but never
  // while a click is opening the panel or the panel is already open.
  readonly property bool useColorTip: root.barWindow !== null && root.tipHtml !== ""
  readonly property bool tipWanted: button.tooltipHovered && !root.opened
    && !root.clickLock && root.useColorTip
  property bool tipShown: false
  property bool clickLock: false

  onOpenedChanged: {
    if (opened) {
      tipDelay.stop()
      tipShown = false
      clickLock = true
      clickLockClear.restart()
    }
  }

  onTipWantedChanged: {
    if (tipWanted) {
      tipDelay.restart()
    } else {
      tipDelay.stop()
      tipShown = false
    }
  }

  Timer {
    id: tipDelay
    interval: 400
    repeat: false
    onTriggered: {
      if (!root.tipWanted) return
      if (root.bar) root.bar.hideTooltip(button)
      root.tipShown = true
    }
  }

  Timer {
    id: clickLockClear
    interval: 500
    repeat: false
    onTriggered: root.clickLock = false
  }

  function armClickLock() {
    tipDelay.stop()
    tipShown = false
    clickLock = true
    clickLockClear.restart()
    if (root.bar) root.bar.hideTooltip(button)
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // Full-width open-panel underline (Bar.qml openPanelIndicator). Without
  // this hint the bar only paints ~55% of the slot, which looks short once
  // Cursor shows several percentage chips.
  readonly property real openPanelIndicatorWidth: Math.max(1, Math.round(button.implicitWidth))
  readonly property real openPanelIndicatorHeight: Math.max(1, Math.round(button.implicitHeight))

  onBarChanged: {
    injectPanel()
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
    active: false
    // Empty while the colored PopupWindow owns the tip; otherwise plain text
    // for the bar's native tooltip (startup / no RAG rows).
    tooltipText: root.useColorTip ? "" : root.tipPlain
    horizontalMargin: 8.5
    fixedWidth: root.bar && root.bar.vertical ? -1 : chipRow.implicitWidth + Style.spaceReal(17)

    onPressed: function(buttonCode) {
      root.armClickLock()
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
      spacing: Style.space(10)
      visible: !(root.bar && root.bar.vertical)

      Repeater {
        id: chipRepeater
        model: root.panelItem ? root.panelItem.barChips : []
        onModelChanged: Qt.callLater(root.syncChipTargets)

        Row {
          id: chipDelegate
          spacing: Style.space(4)
          property var chip: modelData

          function triggerPress(buttonCode) {
            if (buttonCode === Qt.RightButton) root.launchDashboard()
            else if (buttonCode === Qt.MiddleButton) root.nextEntry()
            else if (root.panelItem) root.panelItem.openEntry(chipDelegate.chip.id || "")
          }

          BrandMark {
            anchors.verticalCenter: parent.verticalCenter
            brand: chipDelegate.chip.brand || ""
            fallback: chipDelegate.chip.icon || "󰚩"
            foreground: button.foreground
            fontFamily: button.fontFamily
            fontSize: button.fontSize
          }

          Item {
            width: Style.space(6)
            height: 1
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            visible: !!(chipDelegate.chip.segments && chipDelegate.chip.segments.length > 0
              && chipDelegate.chip.providerPrefix)
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: chipDelegate.chip.providerPrefix || ""
            color: button.foreground
            font.family: button.fontFamily
            font.pixelSize: button.fontSize
          }

          Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            visible: !!(chipDelegate.chip.segments && chipDelegate.chip.segments.length > 0)

            Repeater {
              model: chipDelegate.chip.segments || []

              Text {
                anchors.verticalCenter: parent.verticalCenter
                textFormat: Text.PlainText
                text: modelData.text || ""
                color: root.segmentColor(modelData.severity || "")
                font.family: button.fontFamily
                font.pixelSize: button.fontSize
              }
            }
          }

          Text {
            visible: !(chipDelegate.chip.segments && chipDelegate.chip.segments.length > 0)
              && chipDelegate.chip.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: chipDelegate.chip.label || ""
            color: chipDelegate.chip.alarming && button.useActiveColor
              ? button.activeColor
              : button.foreground
            font.family: button.fontFamily
            font.pixelSize: button.fontSize
          }
        }
      }
    }

    Text {
      visible: root.bar && root.bar.vertical
      anchors.centerIn: parent
      textFormat: Text.PlainText
      text: "󰚩"
      color: button.foreground
      font.family: button.fontFamily
      font.pixelSize: button.fontSize
      rotation: button.textRotation
    }
  }

  // Same PopupWindow + anchor pattern as omarchy bar tooltips (Bar.qml).
  // grabFocus must stay false — otherwise the tip steals input and the
  // click that should open the usage panel only dismisses/shows the tip.
  PopupWindow {
    id: colorTip
    visible: root.tipShown && root.tipWanted
    color: "transparent"
    grabFocus: false
    implicitWidth: Math.max(1, Math.ceil(tipBubble.implicitWidth))
    implicitHeight: Math.max(1, Math.ceil(tipBubble.implicitHeight))

    anchor {
      id: tipAnchor
      window: root.barWindow
      adjustment: PopupAdjustment.Slide
      edges: Edges.Top | Edges.Left
      gravity: Edges.Bottom | Edges.Right
      rect.width: 1
      rect.height: 1

      onAnchoring: {
        var win = root.barWindow
        if (!win || !button) return
        var popupWidth = colorTip.implicitWidth
        var popupHeight = colorTip.implicitHeight
        var localX = button.width / 2 - popupWidth / 2
        var localY = button.height + 6
        if (root.bar && root.bar.position === "bottom") {
          localY = -popupHeight - 6
        } else if (root.bar && root.bar.position === "left") {
          localX = button.width + 6
          localY = button.height / 2 - popupHeight / 2
        } else if (root.bar && root.bar.position === "right") {
          localX = -popupWidth - 6
          localY = button.height / 2 - popupHeight / 2
        }
        var point = win.contentItem.mapFromItem(button, localX, localY)
        tipAnchor.rect.x = Math.round(point.x)
        tipAnchor.rect.y = Math.round(point.y)
      }
    }

    BorderSurface {
      id: tipBubble
      implicitWidth: Math.max(tipLabel.implicitWidth + Style.spacing.controlPaddingX * 2, Style.space(40))
      implicitHeight: Math.max(tipLabel.implicitHeight + Style.spacing.controlPaddingY * 2, Style.space(24))
      color: Color.tooltip.background
      borderSpec: Border.surfaceSpec("tooltip", "border", Color.tooltip.border, 1)
      radius: Style.cornerRadius

      Text {
        id: tipLabel
        anchors.centerIn: parent
        textFormat: Text.RichText
        text: root.tipHtml
        color: Color.tooltip.text
        font.family: button.fontFamily
        font.pixelSize: Style.font.body
        horizontalAlignment: Text.AlignLeft
      }
    }
  }
}
