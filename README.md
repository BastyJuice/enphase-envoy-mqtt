This is a Fork from vk2him "https://github.com/vk2him/Enphase-Envoy-mqtt-json/" Script. This Script Fork has some Bugfixes for reconection issues, rewritten options file, some deprecated functions was updated. The Goal is to run this Script in Docker and work with a Loxberry. This Build runs like a charme with Docker Compose on a Synology with amd64 in Container Manager or Portainer.

# Python script: `Enphase Envoy mqtt to json`

A Python script that takes a real time json stream from an Enphase Envoy and publishes to a mqtt broker. This can then be used for SmartHome Software applications. The data updates at least once per second with negligible load on the Envoy.

Now works with 7.x.x and 8.x.x firmware - thanks to @helderd

**Note - September 2024 - added ability to utilise Battery data on V7 or V8 firmware (v5 not supported) - to enable, turn on the toggle switch BATTERY_INSTALLED in configuration, then setup templates per Battery examples below - thanks to @Underlyingglitch**

**NOTE - this is a breaking change to your templates if you enable the battery Option**

# Requirements

- An Enphase Envoy running 5.x.x, 7.x.x or 8.x.x firmware.
- For 7.x.x and 8.x.x a token is automatically downloaded from Enphase every time the addon is started, so you must include your Enphase account username and password in configutaion
- A mqtt broker that is already running - this can be external or use the `Mosquitto broker` from the Loxberry
    - If you use the Loxberry MQTT Gateway, us the user/password for mqtt as described in the LoxBerry Wiki https://wiki.loxberry.de/plugins/mqtt_gateway/start

# Installation with docker compose

```
services:
  enphase-envoy-mqtt:
    container_name: enphase-envoy-mqtt
    image: ghcr.io/bastyjuice/enphase-envoy-mqtt-json:latest
    network_mode: bridge
    restart: unless-stopped
    volumes:
      - ./options.json:/data/options.json:rw
      - ./token.txt:/data/token.txt:rw
    environment:
      - TZ=Europe/Berlin
```
Be sure you have the valid values in your options.json and a empty token.txt

## Description of labels 
- more info here "https://www.greenwoodsolutions.com.au/news-posts/real-apparent-reactive-power"

```
"production":         = Solar panel production - always positive value
"total-consumption":  = Total Power consumed - always positive value
"net-consumption":    = Total power Consumed minus Solar panel production. Will be positive when importing and negative when exporting
    
    "ph-a" = Phase A    
    "ph-b" = Phase B
    "ph-c" = Phase C

        "p": =  Real Power ** This is the one to use
        "q": =  Reactive Power
        "s": =  Apparent Power
        "v": =  Voltage
        "i": =  Current
        "pf": = Power Factor
        "f": =  Frequency       

Available sensors (with example data):
```json
{
...
"meters": {
        "last_update": 1726696114,
        "soc": 86,
        "main_relay_state": 1,
        "gen_relay_state": 5,
        "backup_bat_mode": 2,
        "backup_soc": 6,
        "is_split_phase": 0,
        "phase_count": 3,
        "enc_agg_soc": 86,
        "enc_agg_energy": 8600,
        "acb_agg_soc": 0,
        "acb_agg_energy": 0,
        "pv": {
            "agg_p_mw": -13884,
            "agg_s_mva": -62992,
            "agg_p_ph_a_mw": -6792,
            "agg_p_ph_b_mw": 0,
            "agg_p_ph_c_mw": -7093,
            "agg_s_ph_a_mva": -61120,
            "agg_s_ph_b_mva": 97423,
            "agg_s_ph_c_mva": -99295
        },
        "storage": {
            "agg_p_mw": -6774000,
            "agg_s_mva": -6812225,
            "agg_p_ph_a_mw": -3383000,
            "agg_p_ph_b_mw": -3391000,
            "agg_p_ph_c_mw": 0,
            "agg_s_ph_a_mva": -3329223,
            "agg_s_ph_b_mva": -3489823,
            "agg_s_ph_c_mva": 6820
        },
        "grid": {
            "agg_p_mw": 7585180,
            "agg_s_mva": 7839779,
            "agg_p_ph_a_mw": 3869223,
            "agg_p_ph_b_mw": 3701411,
            "agg_p_ph_c_mw": 14546,
            "agg_s_ph_a_mva": 3869223,
            "agg_s_ph_b_mva": 3723269,
            "agg_s_ph_c_mva": 247286
        },
        "load": {
            "agg_p_mw": 797296,
            "agg_s_mva": 964562,
            "agg_p_ph_a_mw": 479431,
            "agg_p_ph_b_mw": 310411,
            "agg_p_ph_c_mw": 7453,
            "agg_s_ph_a_mva": 478880,
            "agg_s_ph_b_mva": 330869,
            "agg_s_ph_c_mva": 154811
        },
        "generator": {
            "agg_p_mw": 0,
            "agg_s_mva": 0,
            "agg_p_ph_a_mw": 0,
            "agg_p_ph_b_mw": 0,
            "agg_p_ph_c_mw": 0,
            "agg_s_ph_a_mva": 0,
            "agg_s_ph_b_mva": 0,
            "agg_s_ph_c_mva": 0
        }
    },
...
}
```

# Example output for FW 5
The resulting mqtt topic should look like this example:
```
{
    "production": {
        "ph-a": {
            "p": 351.13,
            "q": 317.292,
            "s": 487.004,
            "v": 244.566,
            "i": 1.989,
            "pf": 0.72,
            "f": 50.0
        },
        "ph-b": {
            "p": 0.0,
            "q": 0.0,
            "s": 0.0,
            "v": 0.0,
            "i": 0.0,
            "pf": 0.0,
            "f": 0.0
        },
        "ph-c": {
            "p": 0.0,
            "q": 0.0,
            "s": 0.0,
            "v": 0.0,
            "i": 0.0,
            "pf": 0.0,
            "f": 0.0
        }
    },
    "net-consumption": {
        "ph-a": {
            "p": 21.397,
            "q": -778.835,
            "s": 865.208,
            "v": 244.652,
            "i": 3.539,
            "pf": 0.03,
            "f": 50.0
        },
        "ph-b": {
            "p": 0.0,
            "q": 0.0,
            "s": 0.0,
            "v": 0.0,
            "i": 0.0,
            "pf": 0.0,
            "f": 0.0
        },
        "ph-c": {
            "p": 0.0,
            "q": 0.0,
            "s": 0.0,
            "v": 0.0,
            "i": 0.0,
            "pf": 0.0,
            "f": 0.0
        }
    },
    "total-consumption": {
        "ph-a": {
            "p": 372.528,
            "q": -1096.126,
            "s": 1352.165,
            "v": 244.609,
            "i": 5.528,
            "pf": 0.28,
            "f": 50.0
        },
        "ph-b": {
            "p": 0.0,
            "q": 0.0,
            "s": 0.0,
            "v": 0.0,
            "i": 0.0,
            "pf": 0.0,
            "f": 0.0
        },
        "ph-c": {
            "p": 0.0,
            "q": 0.0,
            "s": 0.0,
            "v": 0.0,
            "i": 0.0,
            "pf": 0.0,
            "f": 0.0
        }
    }
}
```

__Note:__ Data is provided for three phases - unused phases have values of `0.0`

# Example output for FW 7 and FW 8
The resulting mqtt topic should look like this example:
```
[
    {
        "eid": 704643328,
        "timestamp": 1689409016,
        "actEnergyDlvd": 0.063,
        "actEnergyRcvd": 7939.998,
        "apparentEnergy": 63680.783,
        "reactEnergyLagg": 788.493,
        "reactEnergyLead": 3.712,
        "instantaneousDemand": 0.000,
        "activePower": 0.000,
        "apparentPower": 43.086,
        "reactivePower": -0.000,
        "pwrFactor": 0.000,
        "voltage": 237.151,
        "current": 0.254,
        "freq": 50.000,
        "channels": [
            {
                "eid": 1778385169,
                "timestamp": 1689409016,
                "actEnergyDlvd": 0.063,
                "actEnergyRcvd": 7939.998,
                "apparentEnergy": 63680.783,
                "reactEnergyLagg": 788.493,
                "reactEnergyLead": 3.712,
                "instantaneousDemand": 0.000,
                "activePower": 0.000,
                "apparentPower": 43.086,
                "reactivePower": -0.000,
                "pwrFactor": 0.000,
                "voltage": 237.151,
                "current": 0.254,
                "freq": 50.000
            },
            {
                "eid": 1778385170,
                "timestamp": 1689409016,
                "actEnergyDlvd": 0.061,
                "actEnergyRcvd": 10104.018,
                "apparentEnergy": 31694.583,
                "reactEnergyLagg": 763.996,
                "reactEnergyLead": 7.749,
                "instantaneousDemand": -0.097,
                "activePower": -0.097,
                "apparentPower": 2.779,
                "reactivePower": 0.000,
                "pwrFactor": 0.000,
                "voltage": 9.994,
                "current": 0.278,
                "freq": 50.000
            },
            {
                "eid": 1778385171,
                "timestamp": 1689409016,
                "actEnergyDlvd": 0.000,
                "actEnergyRcvd": 20943.151,
                "apparentEnergy": 22986.373,
                "reactEnergyLagg": 762.634,
                "reactEnergyLead": 0.866,
                "instantaneousDemand": -0.431,
                "activePower": -0.431,
                "apparentPower": 2.006,
                "reactivePower": -0.000,
                "pwrFactor": -1.000,
                "voltage": 10.346,
                "current": 0.194,
                "freq": 50.000
            }
        ]
    },
    {
        "eid": 704643584,
        "timestamp": 1689409016,
        "actEnergyDlvd": 3917484.219,
        "actEnergyRcvd": 637541.835,
        "apparentEnergy": 8370194.604,
        "reactEnergyLagg": 113560.641,
        "reactEnergyLead": 2299086.122,
        "instantaneousDemand": -161.626,
        "activePower": -161.626,
        "apparentPower": 372.559,
        "reactivePower": -212.953,
        "pwrFactor": -0.431,
        "voltage": 237.273,
        "current": 1.571,
        "freq": 50.000,
        "channels": [
            {
                "eid": 1778385425,
                "timestamp": 1689409016,
                "actEnergyDlvd": 3917484.219,
                "actEnergyRcvd": 637541.835,
                "apparentEnergy": 8370194.604,
                "reactEnergyLagg": 113560.641,
                "reactEnergyLead": 2299086.122,
                "instantaneousDemand": -161.626,
                "activePower": -161.626,
                "apparentPower": 372.559,
                "reactivePower": -212.953,
                "pwrFactor": -0.431,
                "voltage": 237.273,
                "current": 1.571,
                "freq": 50.000
            },
            {
                "eid": 1778385426,
                "timestamp": 1689409016,
                "actEnergyDlvd": 0.000,
                "actEnergyRcvd": 18677.254,
                "apparentEnergy": 10322.864,
                "reactEnergyLagg": 798.595,
                "reactEnergyLead": 0.000,
                "instantaneousDemand": -0.222,
                "activePower": -0.222,
                "apparentPower": 0.898,
                "reactivePower": 0.000,
                "pwrFactor": 0.000,
                "voltage": 3.024,
                "current": 0.297,
                "freq": 50.000
            },
            {
                "eid": 1778385427,
                "timestamp": 1689409016,
                "actEnergyDlvd": 0.064,
                "actEnergyRcvd": 27672.079,
                "apparentEnergy": 115.734,
                "reactEnergyLagg": 799.004,
                "reactEnergyLead": 7.648,
                "instantaneousDemand": -0.000,
                "activePower": -0.000,
                "apparentPower": 0.000,
                "reactivePower": 0.000,
                "pwrFactor": 0.000,
                "voltage": 7.651,
                "current": 0.000,
                "freq": 50.000
            }
        ]
    }
]'
```    

## Donation

If this project helps you, you can give me a cup of coffee

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/bastyjuice)
