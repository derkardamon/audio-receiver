-- Force HiFiBerry as default audio output
-- This ensures audio goes to the DAC instead of HDMI

alsa_monitor.rules = {
  {
    matches = {
      {
        { "node.name", "matches", "alsa_output.platform-*hifiberry*" },
      },
    },
    apply_properties = {
      ["node.description"] = "HiFiBerry DAC",
      ["priority.driver"] = 1000,
      ["priority.session"] = 1000,
      ["node.nick"] = "HiFiBerry",
    },
  },
  {
    matches = {
      {
        { "node.name", "matches", "alsa_output.platform-bcm*hdmi*" },
      },
    },
    apply_properties = {
      ["node.disabled"] = true,
    },
  },
  {
    matches = {
      {
        { "device.name", "matches", "alsa_card.platform-*hifiberry*" },
      },
    },
    apply_properties = {
      ["device.description"] = "HiFiBerry DAC+ ADC Pro",
      ["device.nick"] = "HiFiBerry",
      ["priority.driver"] = 2000,
      ["priority.session"] = 2000,
    },
  },
}
