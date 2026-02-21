-- WirePlumber Bluetooth configuration
-- Optimized for audio receiver with auto-switching

bluez_monitor.properties = {
  -- Enable Bluetooth audio devices
  ["bluez5.enable-sbc-xq"] = true,
  ["bluez5.enable-msbc"] = true,
  ["bluez5.enable-hw-volume"] = true,

  -- Audio codecs in order of preference (best quality first)
  ["bluez5.codecs"] = {
    "ldac",      -- Sony LDAC (best quality)
    "aptx_hd",   -- Qualcomm aptX HD
    "aptx",      -- Qualcomm aptX
    "aac",       -- Advanced Audio Coding
    "sbc_xq",    -- SBC with extra quality
    "sbc",       -- Standard SBC (fallback)
  },

  -- Auto-switch to newly connected devices
  ["bluez5.auto-connect"] = true,

  -- LDAC settings for best quality
  ["bluez5.ldac.quality"] = "hq",  -- hq/sq/mq (high/standard/mobile quality)

  -- Enable HFP (hands-free profile) for volume control
  ["bluez5.hfphsp-backend"] = "native",
}

-- Rules for Bluetooth devices
bluez_monitor.rules = {
  {
    matches = {
      {
        -- Match all Bluetooth devices
        { "device.name", "matches", "bluez_card.*" },
      },
    },
    apply_properties = {
      -- Auto-select best quality profile
      ["device.profile"] = "a2dp-sink",

      -- Enable volume control
      ["api.bluez5.connection-info"] = true,

      -- Auto-connect on discovery
      ["bluez5.auto-connect"] = true,
    },
  },
  {
    matches = {
      {
        -- Match all Bluetooth sinks
        { "node.name", "matches", "bluez_output.*" },
      },
    },
    apply_properties = {
      -- Set default audio properties
      ["audio.format"] = "S16LE",
      ["audio.rate"] = 48000,
      ["audio.channels"] = 2,
      ["audio.position"] = "FL,FR",

      -- Prioritize new connections
      ["node.priority"] = 1000,

      -- Auto-connect to this sink
      ["node.autoconnect"] = true,
    },
  },
}
