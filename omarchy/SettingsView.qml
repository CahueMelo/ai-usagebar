import QtQuick
import QtQuick.Controls
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model
import "I18n.js" as I18n

// Native Quattro settings form. Rust remains the sole config owner: this view
// receives only non-secret key-presence metadata and sends changed keys over
// stdin, never argv or the environment.
Column {
  id: root

  property color foreground: Color.foreground
  property color urgent: Color.urgent
  property string fontFamily: Style.font.family
  property bool showValue: true
  property bool showProvider: false
  property bool showAll: false
  property bool colorCodeUsage: false
  property string uiLocale: "en"
  property string uiLocaleSetting: "auto"
  property string barWindow: "auto"
  readonly property color dim: Qt.darker(foreground, 1.45)

  property var snapshot: ({ primary_choices: [], keys: [], vendors: [] })
  property string selectedPrimary: ""
  // Pending provider on/off overrides (#244), keyed by provider id. Rebuilt
  // (never mutated) so the Toggle bindings re-evaluate.
  property var vendorOverrides: ({})
  property int vendorPendingCount: 0
  property string stateStdout: ""
  property string stateStderr: ""
  property string applyStdout: ""
  property string applyStderr: ""
  property string errorText: ""
  property string statusText: ""
  property string pendingPayload: ""
  property int stateExitCode: -1
  property int applyExitCode: -1
  property bool loading: false
  property bool saving: false
  readonly property bool canSave: !loading && !saving
    && (selectedPrimary !== "" || snapshot.primary_choices.length === 0
        || vendorPendingCount > 0)

  signal saved()
  signal fallbackRequested()
  signal nousLoginRequested()
  signal copilotLoginRequested()
  signal showValueRequested(bool enabled)
  signal showProviderRequested(bool enabled)
  signal showAllRequested(bool enabled)
  signal colorCodeUsageRequested(bool enabled)
  signal uiLocaleRequested(string value)
  signal barWindowRequested(string value)
  signal closeRequested()

  spacing: Style.space(12)
  focus: visible
  Keys.onEscapePressed: closeRequested()

  function safe(value) { return Model.autoTextSafe(value) }
  function tr(key, params) { return I18n.t(uiLocale, key, params || null) }

  function load() {
    if (stateProcess.running || applyProcess.running) return
    loading = true
    errorText = ""
    statusText = ""
    stateStdout = ""
    stateStderr = ""
    stateExitCode = -1
    resetVendorOverrides()
    stateProcess.running = true
  }

  function finishLoad() {
    loading = false
    if (stateExitCode !== 0) {
      var detail = Model.errorMessage(stateStderr)
      errorText = detail.indexOf("unrecognized subcommand") >= 0
        ? root.tr("error.binary_old")
        : detail
      snapshot = ({ primary_choices: [], keys: [], vendors: [] })
      selectedPrimary = ""
      return
    }
    var parsed = Model.parseSettingsSnapshot(stateStdout)
    if (!parsed.ok) {
      errorText = parsed.error
      snapshot = ({ primary_choices: [], keys: [], vendors: [] })
      selectedPrimary = ""
      return
    }
    snapshot = parsed
    selectedPrimary = parsed.primary
  }

  function collectChanges() {
    var changes = []
    for (var i = 0; i < keyRepeater.count; i++) {
      var row = keyRepeater.itemAt(i)
      if (!row || row.pendingAction === "unchanged") continue
      changes.push({
        id: row.vendorId,
        action: row.pendingAction,
        value: row.pendingAction === "set" ? row.secretText : ""
      })
    }
    return changes
  }

  function collectVendorToggles() {
    var toggles = []
    for (var id in root.vendorOverrides) {
      if (Object.prototype.hasOwnProperty.call(root.vendorOverrides, id))
        toggles.push({ id: id, enabled: root.vendorOverrides[id] })
    }
    return toggles
  }

  // Record one pending provider switch (#244). A value equal to the snapshot
  // drops the override, so toggling twice returns the row to "unchanged".
  function setVendorOverride(id, enabled) {
    var next = {}
    var base = snapshot.vendors || []
    var current = null
    for (var i = 0; i < base.length; i++) {
      if (base[i].id === id) current = base[i].enabled
    }
    for (var key in root.vendorOverrides) {
      if (Object.prototype.hasOwnProperty.call(root.vendorOverrides, key) && key !== id)
        next[key] = root.vendorOverrides[key]
    }
    if (enabled !== current) next[id] = enabled
    vendorOverrides = next
    vendorPendingCount = Object.keys(next).length
  }

  function resetVendorOverrides() {
    vendorOverrides = ({})
    vendorPendingCount = 0
  }

  function save() {
    if (!canSave) return
    var built = Model.buildSettingsPatch(selectedPrimary, collectChanges(), collectVendorToggles())
    if (!built.ok) {
      errorText = built.error
      return
    }
    saving = true
    errorText = ""
    statusText = ""
    applyStdout = ""
    applyStderr = ""
    applyExitCode = -1
    pendingPayload = built.payload
    applyProcess.running = true
  }

  function scrubSecrets() {
    pendingPayload = ""
    for (var i = 0; i < keyRepeater.count; i++) {
      var row = keyRepeater.itemAt(i)
      if (row) row.scrub()
    }
  }

  function finishApply() {
    saving = false
    // The Rust process has consumed the stdin patch. Do not retain credentials
    // in this long-lived shell, even if the save failed.
    scrubSecrets()
    if (applyExitCode !== 0 || !Model.parseSettingsApplyResult(applyStdout)) {
      errorText = Model.errorMessage(applyStderr || root.tr("error.apply"))
      return
    }
    saved()
    load()
    // load() clears stale status before refreshing the snapshot, so set the
    // confirmation afterwards and keep it visible while the refresh runs.
    statusText = root.tr("status.saved")
  }

  onVisibleChanged: {
    if (visible) {
      load()
      Qt.callLater(function() { root.forceActiveFocus() })
    }
    else scrubSecrets()
  }

  Process {
    id: stateProcess
    running: false
    command: ["ai-usagebar", "settings", "show"]

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.stateStdout = text
    }
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.stateStderr = text
    }
    onExited: function(exitCode, exitStatus) {
      root.stateExitCode = exitCode
      Qt.callLater(root.finishLoad)
    }
  }

  Process {
    id: applyProcess
    running: false
    command: ["ai-usagebar", "settings", "apply"]
    stdinEnabled: true

    onStarted: {
      write(root.pendingPayload + "\n")
      root.pendingPayload = ""
    }
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyStdout = text
    }
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyStderr = text
    }
    onExited: function(exitCode, exitStatus) {
      root.applyExitCode = exitCode
      Qt.callLater(root.finishApply)
    }
  }

  Column {
    visible: root.loading
    width: parent.width
    spacing: Style.space(8)

    PanelSectionHeader {
      text: root.tr("section.settings")
      foreground: root.foreground
      fontFamily: root.fontFamily
    }
    Text {
      width: parent.width
      text: root.tr("loading.config")
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      horizontalAlignment: Text.AlignHCenter
    }
  }

  Column {
    visible: !root.loading
    width: parent.width
    spacing: Style.space(8)

    PanelSectionHeader {
      text: root.tr("section.display")
      foreground: root.foreground
      fontFamily: root.fontFamily
    }
    Toggle {
      width: parent.width
      label: root.tr("toggle.show_value")
      description: root.tr("toggle.show_value_desc")
      checked: root.showValue
      foreground: root.foreground
      fontFamily: root.fontFamily
      enabled: !root.saving
      onClicked: root.showValueRequested(!root.showValue)
    }
    Toggle {
      width: parent.width
      label: root.tr("toggle.show_provider")
      description: root.tr("toggle.show_provider_desc")
      checked: root.showProvider
      foreground: root.foreground
      fontFamily: root.fontFamily
      enabled: !root.saving
      onClicked: root.showProviderRequested(!root.showProvider)
    }
    Toggle {
      width: parent.width
      label: root.tr("toggle.show_all")
      description: root.tr("toggle.show_all_desc")
      checked: root.showAll
      foreground: root.foreground
      fontFamily: root.fontFamily
      enabled: !root.saving
      onClicked: root.showAllRequested(!root.showAll)
    }
    Toggle {
      width: parent.width
      label: root.tr("toggle.color_code")
      description: root.tr("toggle.color_code_desc")
      checked: root.colorCodeUsage
      foreground: root.foreground
      fontFamily: root.fontFamily
      enabled: !root.saving
      onClicked: root.colorCodeUsageRequested(!root.colorCodeUsage)
    }
  }

  Column {
    visible: !root.loading
    width: parent.width
    spacing: Style.space(8)

    PanelSectionHeader {
      text: root.tr("section.language")
      foreground: root.foreground
      fontFamily: root.fontFamily
    }
    Text {
      width: parent.width
      text: root.tr("language.help")
      textFormat: Text.PlainText
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }
    Dropdown {
      width: parent.width
      showLabel: false
      value: {
        var tag = I18n.normalizeLocaleTag(root.uiLocaleSetting)
        return tag === "" ? "auto" : tag
      }
      options: [
        { value: "auto", label: root.tr("language.auto") },
        { value: "en", label: root.tr("language.en") },
        { value: "pt-BR", label: root.tr("language.pt-BR") },
        { value: "ru", label: root.tr("language.ru") }
      ]
      foreground: root.foreground
      fontFamily: root.fontFamily
      enabled: !root.saving
      onChanged: function(value) { root.uiLocaleRequested(value) }
    }
  }

  Column {
    visible: !root.loading
    width: parent.width
    spacing: Style.space(8)

    PanelSectionHeader {
      text: root.tr("section.bar_window")
      foreground: root.foreground
      fontFamily: root.fontFamily
    }
    Text {
      width: parent.width
      text: root.tr("bar_window.help")
      textFormat: Text.PlainText
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }
    Dropdown {
      width: parent.width
      showLabel: false
      value: Model.normalizeBarWindow(root.barWindow)
      options: [
        { value: "auto", label: root.tr("bar_window.auto") },
        { value: "session", label: root.tr("bar_window.session") },
        { value: "weekly", label: root.tr("bar_window.weekly") },
        { value: "monthly", label: root.tr("bar_window.monthly") }
      ]
      foreground: root.foreground
      fontFamily: root.fontFamily
      enabled: !root.saving
      onChanged: function(value) { root.barWindowRequested(value) }
    }
  }

  BorderSurface {
    visible: root.errorText !== ""
    width: parent.width
    implicitHeight: errorColumn.implicitHeight + Style.spacing.xl * 2
    color: Qt.rgba(root.urgent.r, root.urgent.g, root.urgent.b, 0.09)
    borderSpec: Border.flat(Qt.rgba(root.urgent.r, root.urgent.g, root.urgent.b, 0.35), 1)
    radius: Style.cornerRadius

    Column {
      id: errorColumn
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(12)
      anchors.rightMargin: Style.space(12)
      spacing: Style.space(8)

      Text {
        width: parent.width
        text: root.safe(root.errorText)
        textFormat: Text.PlainText
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        wrapMode: Text.WordWrap
      }
      Row {
        spacing: Style.space(8)
        Button {
          text: root.tr("action.retry")
          bordered: true
          focusable: true
          foreground: root.foreground
          fontFamily: root.fontFamily
          onClicked: root.load()
        }
        Button {
          text: root.tr("action.terminal_settings")
          bordered: true
          focusable: true
          foreground: root.foreground
          fontFamily: root.fontFamily
          onClicked: root.fallbackRequested()
        }
      }
    }
  }

  Column {
    visible: !root.loading && root.snapshot.primary_choices.length > 0
    width: parent.width
    spacing: Style.space(8)

    PanelSectionHeader {
      text: root.tr("section.primary")
      foreground: root.foreground
      fontFamily: root.fontFamily
    }
    Text {
      width: parent.width
      text: root.tr("primary.help")
      textFormat: Text.PlainText
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }
    Dropdown {
      id: primaryDropdown
      width: parent.width
      showLabel: false
      value: root.selectedPrimary
      options: root.snapshot.primary_choices
      foreground: root.foreground
      fontFamily: root.fontFamily
      enabled: !root.saving
      onChanged: function(value) { root.selectedPrimary = value }
    }
  }

  Column {
    visible: !root.loading && root.snapshot.vendors.length > 0
    width: parent.width
    spacing: Style.space(8)

    PanelSeparator {
      width: parent.width
      foreground: root.foreground
    }
    PanelSectionHeader {
      text: root.tr("section.providers")
      foreground: root.foreground
      fontFamily: root.fontFamily
    }
    Text {
      width: parent.width
      text: root.tr("providers.help")
      textFormat: Text.PlainText
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }
    Repeater {
      model: root.snapshot.vendors

      Toggle {
        required property var modelData
        width: parent.width
        label: root.safe(modelData.label)
        description: {
          var pending = root.vendorOverrides[modelData.id]
          var effective = pending === true || pending === false ? pending : modelData.enabled
          return effective ? root.tr("status.vendor_on") : root.tr("status.vendor_off")
        }
        checked: {
          var pending = root.vendorOverrides[modelData.id]
          return pending === true || pending === false ? pending : modelData.enabled
        }
        foreground: root.foreground
        fontFamily: root.fontFamily
        enabled: !root.saving
        onClicked: root.setVendorOverride(modelData.id, !checked)
      }
    }
  }

  Column {
    visible: !root.loading
    width: parent.width
    spacing: Style.space(10)

    PanelSeparator {
      width: parent.width
      foreground: root.foreground
    }
    PanelSectionHeader {
      text: root.tr("section.auth")
      foreground: root.foreground
      fontFamily: root.fontFamily
    }
    Text {
      width: parent.width
      text: root.tr("auth.help")
      textFormat: Text.PlainText
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }
    Button {
      width: parent.width
      text: root.tr("auth.nous")
      iconText: "󰍂"
      bordered: true
      focusable: true
      foreground: root.foreground
      fontFamily: root.fontFamily
      enabled: !root.saving
      onClicked: {
        root.statusText = root.tr("status.nous_login")
        root.nousLoginRequested()
      }
    }
    Button {
      width: parent.width
      text: root.tr("auth.copilot")
      iconText: "󰊤"
      bordered: true
      focusable: true
      foreground: root.foreground
      fontFamily: root.fontFamily
      enabled: !root.saving
      onClicked: {
        root.statusText = root.tr("status.copilot_login")
        root.copilotLoginRequested()
      }
    }
  }

  Column {
    visible: !root.loading && root.snapshot.keys.length > 0
    width: parent.width
    spacing: Style.space(10)

    PanelSeparator {
      width: parent.width
      foreground: root.foreground
    }
    PanelSectionHeader {
      text: root.tr("section.credentials")
      foreground: root.foreground
      fontFamily: root.fontFamily
    }
    Text {
      width: parent.width
      text: root.tr("credentials.help")
      textFormat: Text.PlainText
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }

    Repeater {
      id: keyRepeater
      model: root.snapshot.keys

      BorderSurface {
        id: keyCard
        required property var modelData
        readonly property string vendorId: String(modelData.id || "")
        property string pendingAction: "unchanged"
        property alias secretText: keyField.text

        function scrub() {
          keyField.text = ""
          pendingAction = "unchanged"
        }

        width: keyRepeater.parent.width
        implicitHeight: keyColumn.implicitHeight + Style.spacing.xl * 2
        color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.035)
        borderSpec: Border.flat(Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.10), 1)
        radius: Style.cornerRadius

        Column {
          id: keyColumn
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: Style.space(12)
          anchors.rightMargin: Style.space(12)
          spacing: Style.space(6)

          Item {
            width: parent.width
            implicitHeight: Math.max(keyLabel.implicitHeight, keyStatus.implicitHeight)

            Text {
              id: keyLabel
              anchors.left: parent.left
              anchors.right: keyStatus.left
              anchors.rightMargin: Style.spacing.md
              text: root.safe(keyCard.modelData.label)
              textFormat: Text.PlainText
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              elide: Text.ElideRight
            }
            Text {
              id: keyStatus
              anchors.right: parent.right
              text: keyCard.pendingAction === "clear" ? root.tr("status.will_clear")
                : keyCard.pendingAction === "set" ? root.tr("credentials.new_key")
                : keyCard.modelData.environment_configured ? root.tr("credentials.env_override")
                : keyCard.modelData.inline_configured ? root.tr("credentials.stored")
                : root.tr("credentials.not_configured")
              textFormat: Text.PlainText
              color: keyCard.pendingAction === "clear" ? root.urgent : root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }
          }

          // Env var stays on its own line (identifier, may elide). Role +
          // note wrap below so long hints are readable instead of cutting
          // mid-word as "mont…" / "sp…".
          Text {
            visible: text !== ""
            width: parent.width
            text: keyCard.modelData.environment ? root.safe(keyCard.modelData.environment) : ""
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
          }
          Text {
            visible: text !== ""
            width: parent.width
            text: {
              var parts = []
              var secret = I18n.displaySecretLabel(root.uiLocale, keyCard.modelData.secret_label)
              var note = I18n.displayNote(root.uiLocale, keyCard.modelData.note)
              if (secret) parts.push(secret)
              if (note) parts.push(note)
              return parts.join(" · ")
            }
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
          }

          Row {
            width: parent.width
            spacing: Style.space(8)

            TextField {
              id: keyField
              width: parent.width - clearButton.width - parent.spacing
              password: true
              enabled: !root.saving && keyCard.pendingAction !== "clear"
              placeholderText: keyCard.modelData.configured
                ? root.tr("credentials.keep_blank")
                : root.tr("credentials.paste", {
                    label: I18n.displaySecretLabel(root.uiLocale, keyCard.modelData.secret_label)
                      || root.tr("credentials.credential")
                  })
              foreground: root.foreground
              onTextEdited: keyCard.pendingAction = text.length > 0 ? "set" : "unchanged"
              Keys.onEscapePressed: focus = false
              onAccepted: root.save()
            }

            PanelActionButton {
              id: clearButton
              anchors.verticalCenter: keyField.verticalCenter
              iconText: keyCard.pendingAction === "clear" ? "󰕌" : "󰆴"
              tooltipText: keyCard.pendingAction === "clear"
                ? root.tr("credentials.keep_key") : root.tr("credentials.clear_key")
              foreground: root.foreground
              hoverColor: keyCard.pendingAction === "clear" ? root.foreground : root.urgent
              fontFamily: root.fontFamily
              focusable: true
              enabled: !root.saving && (keyCard.modelData.inline_configured || keyCard.pendingAction === "clear")
              onClicked: {
                if (keyCard.pendingAction === "clear") {
                  keyCard.pendingAction = "unchanged"
                } else {
                  keyField.text = ""
                  keyCard.pendingAction = "clear"
                }
              }
            }
          }
        }
      }
    }
  }

  BorderSurface {
    visible: root.statusText !== ""
    width: parent.width
    implicitHeight: savedText.implicitHeight + Style.spacing.lg * 2
    color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.06)
    borderSpec: Border.flat(Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.18), 1)
    radius: Style.cornerRadius

    Text {
      id: savedText
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(12)
      anchors.rightMargin: Style.space(12)
      text: root.safe(root.statusText)
      textFormat: Text.PlainText
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      horizontalAlignment: Text.AlignHCenter
    }
  }

  Button {
    visible: !root.loading
      && (root.snapshot.primary_choices.length > 0 || root.snapshot.keys.length > 0
          || root.snapshot.vendors.length > 0)
    width: parent.width
    text: root.saving ? root.tr("action.saving") : root.tr("action.save")
    iconText: root.saving ? "󰑐" : "󰄬"
    iconSpinning: root.saving
    bordered: true
    focusable: true
    foreground: root.foreground
    fontFamily: root.fontFamily
    enabled: root.canSave
    onClicked: root.save()
  }
}
