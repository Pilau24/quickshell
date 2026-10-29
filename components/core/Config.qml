import Quickshell
import Quickshell.Io
import QtQuick

Item {
  id: root

  visible: false

  readonly property int defaultBarHeight: 32
  property string currentTheme: "catppuccin-mocha"
  property string primaryMonitor: "HDMI-A-1"
  property var theme: null
  property bool themeLoaded: false
  property bool themeFallbackAttempted: false
  property bool debug: false
  readonly property var themeIds: [
    "catppuccin-latte",
    "catppuccin-frappe",
    "catppuccin-macchiato",
    "catppuccin-mocha"
  ]
  readonly property string themePath: Quickshell.shellDir + "/themes/" + currentTheme + ".toml"

  readonly property color barBackground: theme ? theme.colors.background : "#1e1e2e"
  readonly property color barText: theme ? theme.colors.text : "#cdd6f4"
  readonly property color panelSurface: theme ? theme.colors.surface : "#313244"
  readonly property color accent: theme ? theme.colors.accent : "#cba6f7"
  readonly property color panelText: theme ? theme.colors.text : "#cdd6f4"
  readonly property color muted: theme ? theme.colors.muted : "#a6adc8"
  readonly property color urgent: theme ? theme.colors.urgent : "#f38ba8"
  readonly property color color0: theme ? theme.colors.color0 : "#45475a"
  readonly property color color1: theme ? theme.colors.color1 : "#f38ba8"
  readonly property color color2: theme ? theme.colors.color2 : "#a6e3a1"
  readonly property color color3: theme ? theme.colors.color3 : "#f9e2af"
  readonly property color color4: theme ? theme.colors.color4 : "#89b4fa"
  readonly property color color5: theme ? theme.colors.color5 : "#f5c2e7"
  readonly property color color6: theme ? theme.colors.color6 : "#94e2d5"
  readonly property color color7: theme ? theme.colors.color7 : "#a6adc8"
  readonly property color color8: theme ? theme.colors.color8 : "#585b70"
  readonly property color color9: theme ? theme.colors.color9 : "#f37799"
  readonly property color color10: theme ? theme.colors.color10 : "#89d88b"
  readonly property color color11: theme ? theme.colors.color11 : "#ebd391"
  readonly property color color12: theme ? theme.colors.color12 : "#74a8fc"
  readonly property color color13: theme ? theme.colors.color13 : "#f2aede"
  readonly property color color14: theme ? theme.colors.color14 : "#6bd7ca"
  readonly property color color15: theme ? theme.colors.color15 : "#bac2de"
  readonly property string barFont: theme ? theme.font : "Sans"
  readonly property int barFontSize: theme ? theme["font-size-body"] : 14
  readonly property int barFontWeight: theme ? theme["font-weight-body"] : 400
  readonly property int textXs: theme ? theme["text-xs"] : 12
  readonly property int textSm: theme ? theme["text-sm"] : 14
  readonly property int textBase: theme ? theme["text-base"] : 16
  readonly property int textLg: theme ? theme["text-lg"] : 18
  readonly property int textXl: theme ? theme["text-xl"] : 20
  readonly property int text2xl: theme ? theme["text-2xl"] : 24
  readonly property int barHeight: theme ? theme["bar-height"] : defaultBarHeight
  readonly property int panelMargin: theme ? theme["panel-margin"] : 0
  readonly property int panelPadding: theme ? theme["panel-padding"] : 0
  readonly property int roundingPx: theme ? theme["rounding-px"] : 6
  readonly property string configPath: Quickshell.shellDir + "/config.toml"

  function setSetting(key, value) {
    if (key === "currentTheme") {
      if (!themeIds.includes(value)) return
      currentTheme = value
      loadTheme()
    } else if (key === "primaryMonitor") {
      if (typeof value !== "string" || value.length === 0) return
      primaryMonitor = value
    } else {
      console.warn("Unknown setting:", key)
      return
    }

    const literal = typeof value === "string" ? `"${value}"` : String(value)
    saveProcess.command = ["sed", "-i", "-E", `s|^${key}[[:space:]]*=.*|${key} = ${literal}|`, configPath]
    saveProcess.running = true
  }

  Process {
    id: saveProcess
  }

  function loadTheme() {
    themeLoaded = false
    themeFallbackAttempted = currentTheme === "catppuccin-mocha"
    themeProcess.running = false
    Qt.callLater(() => themeProcess.running = true)
  }

  readonly property string resolvedPrimaryMonitor: {
    for (const screen of Quickshell.screens) {
      if (screen.name === primaryMonitor) return primaryMonitor
    }
    return Quickshell.screens.length > 0 ? Quickshell.screens[0].name : ""
  }

  Process {
    command: ["tomlq", ".", root.configPath]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const config = JSON.parse(this.text)

          if (typeof config.currentTheme === "string" && config.currentTheme.length > 0) {
            root.currentTheme = root.themeIds.includes(config.currentTheme)
              ? config.currentTheme
              : "catppuccin-mocha"
          }
          if (typeof config.primaryMonitor === "string" && config.primaryMonitor.length > 0) {
            root.primaryMonitor = config.primaryMonitor
          }
          if (typeof config.debug === "boolean") root.debug = config.debug
          root.loadTheme()
        } catch (error) {
          console.warn("Failed to load config.toml; using default settings:", error)
          root.loadTheme()
        }
      }
    }
  }

  Process {
    id: themeProcess
    command: ["tomlq", ".", root.themePath]

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const loadedTheme = JSON.parse(this.text)
          const requiredColors = [
            "color0", "color1", "color2", "color3", "color4", "color5", "color6", "color7",
            "color8", "color9", "color10", "color11", "color12", "color13", "color14", "color15",
            "background", "surface", "accent", "text", "muted"
          ]
          if (typeof loadedTheme.name !== "string"
              || typeof loadedTheme.family !== "string"
              || typeof loadedTheme.desc !== "string"
              || typeof loadedTheme.light !== "boolean"
              || typeof loadedTheme.font !== "string"
              || !Number.isFinite(loadedTheme["font-size-heading"])
              || !Number.isFinite(loadedTheme["font-size-body"])
              || !Number.isFinite(loadedTheme["font-weight-heading"])
              || !Number.isFinite(loadedTheme["font-weight-body"])
              || !Number.isFinite(loadedTheme["text-xs"])
              || !Number.isFinite(loadedTheme["text-sm"])
              || !Number.isFinite(loadedTheme["text-base"])
              || !Number.isFinite(loadedTheme["text-lg"])
              || !Number.isFinite(loadedTheme["text-xl"])
              || !Number.isFinite(loadedTheme["text-2xl"])
              || !Number.isInteger(loadedTheme["rounding-px"])
              || !Number.isInteger(loadedTheme["bar-height"])
              || !Number.isInteger(loadedTheme["panel-margin"])
              || !Number.isInteger(loadedTheme["panel-padding"])
              || typeof loadedTheme.colors !== "object"
              || requiredColors.some(name => typeof loadedTheme.colors[name] !== "string"
                || !/^#[0-9a-fA-F]{6}$/.test(loadedTheme.colors[name]))) {
            throw new Error("Theme metadata is incomplete")
          }
          root.theme = loadedTheme
          root.themeLoaded = true
        } catch (error) {
          if (!root.themeFallbackAttempted) {
            console.warn("Failed to load theme", root.currentTheme, "; falling back to Catppuccin Mocha:", error)
            root.currentTheme = "catppuccin-mocha"
            root.themeFallbackAttempted = true
            root.loadTheme()
          } else {
            console.warn("Failed to load Catppuccin Mocha theme:", error)
            root.theme = null
            root.themeLoaded = false
          }
        }
      }
    }
  }
}