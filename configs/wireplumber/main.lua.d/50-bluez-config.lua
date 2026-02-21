-- WirePlumber Bluetooth Configuration (Modern Format)
-- For WirePlumber 0.5.0+ using new Lua configuration system
-- Optimized for Bluetooth audio receiver with HiFiBerry DAC

-- Load required API
bluez_monitor = {}

-- Basic Bluetooth monitor configuration
bluez_monitor.properties = {
  -- Enable high-quality SBC and mSBC
  ["bluez5.enable-sbc-xq"] = true,
  ["bluez5.enable-msbc"] = true,

  -- Enable hardware volume control
  ["bluez5.enable-hw-volume"] = true,

  -- Audio codecs in preference order (best quality first)
  ["bluez5.codecs"] = "[ ldac aptx_hd aptx aac sbc_xq sbc ]",

  -- Auto-connect to paired devices
  ["bluez5.auto-connect"] = "[ hfp_hf hfp_ag hsp_hs hsp_ag a2dp_sink a2dp_source ]",

  -- LDAC quality setting (hq = high quality)
  ["bluez5.ldac.quality"] = "hq",

  -- Use native HFP backend
  ["bluez5.hfphsp-backend"] = "native",

  -- Enable media role
  ["bluez5.roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag a2dp_sink a2dp_source ]",
}

-- Device matching rules
bluez_monitor.rules = {
  -- Rule for all Bluetooth audio devices
  {
    matches = {
      {
        { "device.name", "matches", "bluez_card.*" },
      },
    },
    apply_properties = {
      -- Select A2DP sink profile (receiving audio)
      ["device.profile"] = "a2dp-sink",

      -- Enable connection info
      ["api.bluez5.connection-info"] = "true",

      -- Auto-connect when device is available
      ["bluez5.auto-connect"] = "true",

      -- Higher priority for Bluetooth devices
      ["priority.driver"] = 1000,
      ["priority.session"] = 1000,
    },
  },

  -- Rule for Bluetooth audio nodes
  {
    matches = {
      {
        { "node.name", "matches", "bluez_*put.*" },
      },
    },
    apply_properties = {
      -- Audio format settings
      ["audio.format"] = "S16LE",
      ["audio.rate"] = 48000,
      ["audio.channels"] = 2,
      ["audio.position"] = "FL,FR",

      -- Set high priority
      ["node.priority"] = 1000,

      -- Auto-connect nodes
      ["node.autoconnect"] = "true",

      -- Session management
      ["session.suspend-timeout-seconds"] = 0,
    },
  },

  -- Rule for A2DP sink streams
  {
    matches = {
      {
        { "node.name", "matches", "bluez_input.*a2dp*" },
      },
    },
    apply_properties = {
      -- Media role for routing
      ["media.role"] = "Music",

      -- Latency settings
      ["node.latency"] = "1024/48000",

      -- Auto-connect
      ["node.autoconnect"] = "true",

      -- Keep alive
      ["session.suspend-timeout-seconds"] = 0,
    },
  },
}

-- Apply configuration
table.insert(alsa_monitor.rules, bluez_monitor.rules)
