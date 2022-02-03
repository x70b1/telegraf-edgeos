package all

import (
	_ "github.com/influxdata/telegraf/plugins/inputs/bond"
	_ "github.com/influxdata/telegraf/plugins/inputs/cpu"
	_ "github.com/influxdata/telegraf/plugins/inputs/disk"
	_ "github.com/influxdata/telegraf/plugins/inputs/diskio"
	_ "github.com/influxdata/telegraf/plugins/inputs/dns_query"
	_ "github.com/influxdata/telegraf/plugins/inputs/ethtool"
	_ "github.com/influxdata/telegraf/plugins/inputs/exec"
	_ "github.com/influxdata/telegraf/plugins/inputs/http_response"
	_ "github.com/influxdata/telegraf/plugins/inputs/internal"
	_ "github.com/influxdata/telegraf/plugins/inputs/internet_speed"
	_ "github.com/influxdata/telegraf/plugins/inputs/iptables"
	_ "github.com/influxdata/telegraf/plugins/inputs/mem"
	_ "github.com/influxdata/telegraf/plugins/inputs/net"
	_ "github.com/influxdata/telegraf/plugins/inputs/net_response"
	_ "github.com/influxdata/telegraf/plugins/inputs/ping"
	_ "github.com/influxdata/telegraf/plugins/inputs/processes"
	_ "github.com/influxdata/telegraf/plugins/inputs/snmp"
	_ "github.com/influxdata/telegraf/plugins/inputs/snmp_legacy"
	_ "github.com/influxdata/telegraf/plugins/inputs/snmp_trap"
	_ "github.com/influxdata/telegraf/plugins/inputs/system"
)
