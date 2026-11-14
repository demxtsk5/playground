# Docker-Container Übersicht

Diese Übersicht beschreibt die auf dem Raspberry Pi eingesetzten Dienste, ihre Aufgaben im Heimnetz, die Netzwerk-Architektur sowie die zugehörigen lokalen und öffentlichen Zugriffsadressen.

## Zugriffsübersicht

| Dienst | Container | Lokale URL (Heimnetz / VPN) | Öffentliche URL (Internet) |
| :--- | :--- | :--- | :--- |
| **Caddy** | `caddy` | — *(Reverse Proxy)* | — *(Reverse Proxy)* |
| **Pi-hole** | `pihole` | https://pihole.lan | *Nur lokal erreichbar* |
| **Portainer** | `portainer` | https://portainer.lan | https://duckdns.org |
| **Dozzle** | `dozzle` | https://dozzle.lan | https://duckdns.org |
| **Beszel** | `beszel` / `beszel-agent` | https://beszel.lan | https://duckdns.org |
| **Uptime Kuma** | `uptime-kuma` | https://kuma.lan | https://duckdns.org |
| **SearXNG** | `searxng` | https://searx.lan | *Nur lokal erreichbar* |
| **Lynis Report** | `lynis-report` | *Über Dozzle einsehbar* | *Über Dozzle einsehbar* |

---

## Netzwerk-Architektur

Das Setup nutzt ein abgeschottetes Docker-Netzwerk (`caddy_net`), sodass die einzelnen Web-Container keine eigenen Ports mehr auf dem Host öffnen müssen. Der gesamte HTTP/HTTPS-Verkehr läuft zwingend über Caddy als zentralen Einstiegspunkt.

```text
  [ Internet / Mobilfunk ]                 [ Heimnetz / WLAN ]
             │                                      │
      (Port 80 & 443)                        (Port 53)    (Port 80 & 443)
             ▼                                      ▼            ▼
  ┌─────────────────────┐                ┌──────────────────────────────┐
  │      FRITZ!Box      │                │         Raspberry Pi         │
  │  Portweiterleitung  │───────────────►│  ┌────────┐      ┌────────┐  │
  │    & DuckDNS-Sync   │                │  │Pi-hole │      │ Caddy  │  │
  └─────────────────────┘                │  │(DNS 53)│      │(Proxy) │  │
                                         │  └────────┘      └───┬────┘  │
                                         │                      │       │
                                         │    ┌─────────────────┴──┐    │
                                         │    │  Docker-Netzwerk   │    │
                                         │    │    (caddy_net)     │    │
                                         │    │                    │    │
                                         │    │ • pihole:80        │    │
                                         │    │ • portainer:9000   │    │
                                         │    │ • dozzle:8080      │    │
                                         │    │ • beszel:8090      │    │
                                         │    │ • uptime-kuma:3001 │    │
                                         │    │ • searxng:8080     │    │
                                         │    └────────────────────┘    │
                                         │                              │
                                         │  [beszel-agent] ──►127.0.0.1 │
                                         └──────────────────────────────┘
```

### Sicherheitskonzept & Port-Freigaben

* **FRITZ!Box (nach außen geöffnet):** Lediglich die Ports **80 (TCP)** für Let's Encrypt und **443 (TCP)** für verschlüsseltes HTTPS sind an den Raspberry Pi weitergeleitet.
* **Caddy (`0.0.0.0:80`, `0.0.0.0:443`):** Nimmt alle externen und internen Web-Anfragen entgegen, terminiert SSL/TLS (Let's Encrypt für `.duckdns.org`, interne Root-CA für `.lan`) und leitet den Traffic intern über `caddy_net` an die Containernamen weiter.
* **Pi-hole (`0.0.0.0:53`):** Lauscht im Heimnetz ausschließlich auf Port 53 (TCP/UDP) für DNS-Anfragen und löst die lokalen `.lan`-Domains auf die IP des Raspberry Pi (`192.168.178.140`) auf.
* **Beszel (`127.0.0.1:8090`):** Der Web-Port ist ausschließlich auf Localhost gebunden, damit der im Host-Netzwerk laufende `beszel-agent` seine Systemdaten sicher lokal einliefern kann.
* **Abgeschottete Container:** Portainer, Dozzle, Uptime Kuma und SearXNG besitzen keine offenen Host-Ports und sind weder aus dem WLAN noch aus dem Internet direkt ansprechbar.

---

## Dienstbeschreibungen

### Caddy (`caddy`)
Caddy ist ein moderner Webserver und Reverse Proxy, der alle eingehenden Anfragen zentral entgegennimmt und an die richtigen Container weiterleitet. Er verwaltet SSL-Zertifikate vollautomatisch, sowohl intern für das lokale Netzwerk als auch öffentlich über Let's Encrypt. Dadurch sind sämtliche Dienste sicher per HTTPS und ohne störende Portnummern erreichbar.

### Pi-hole (`pihole`)
Pi-hole fungiert als netzwerkweiter Werbe- und Tracker-Blocker auf DNS-Ebene für alle Geräte im WLAN. Zusätzlich dient er als lokaler DNS-Server, der interne Namen wie `.lan` auf die IP-Adresse des Raspberry Pi auflöst. Durch die Filterung unerwünschter Domains vor dem eigentlichen Seitenaufbau erhöht er sowohl den Datenschutz als auch die Ladegeschwindigkeit im gesamten Heimnetz.

### Portainer (`portainer`)
Portainer bietet eine übersichtliche Weboberfläche zur Verwaltung der gesamten Docker-Umgebung. Über das Dashboard lassen sich Container, Images, Volumes und Netzwerke bequem starten, stoppen, aktualisieren oder neu konfigurieren. Das vereinfacht die Wartung erheblich, ohne dass für jede kleine Aufgabe eine SSH-Verbindung aufgebaut werden muss.

### Dozzle (`dozzle`)
Dozzle ist ein schlanker Echtzeit-Log-Viewer für Docker-Container im Browser. Er liest die Ausgaben aller laufenden Dienste direkt über den Docker-Socket aus, ohne selbst große Datenmengen auf der Festplatte zu speichern. Bei Fehlern oder Neustarts lassen sich damit einzelne Dienste schnell und übersichtlich nach Schlagwörtern durchsuchen.

### Beszel (`beszel` & `beszel-agent`)
Beszel ist ein ressourcenschonendes Monitoring-System zur Überwachung der Server-Auslastung. Der zugehörige Agent erfasst kontinuierlich Werte wie CPU-Last, Arbeitsspeicher, Festplattenbelegung und Docker-Statistiken direkt auf dem Host. Das Web-Dashboard bereitet diese Kennzahlen in übersichtlichen Verlaufsdiagrammen auf und kann bei kritischen Schwellenwerten warnen.

### Uptime Kuma (`uptime-kuma`)
Uptime Kuma überwacht rund um die Uhr die Erreichbarkeit und Antwortzeiten von Webseiten, Diensten und Docker-Containern. Fällt ein Dienst aus oder läuft ein Zertifikat ab, verschickt das Tool sofort Benachrichtigungen über Dienste wie Telegram, E-Mail oder Pushover. Eine grafische Statusübersicht zeigt zudem langfristig die Verfügbarkeit der gesamten Infrastruktur.

### SearXNG (`searxng`)
SearXNG ist eine datenschutzfreundliche Metasuchmaschine, die Suchanfragen anonymisiert an verschiedene große Suchmaschinen weiterleitet. Sie fasst die Ergebnisse übersichtlich zusammen, ohne Nutzerprofile anzulegen, IP-Adressen zu speichern oder Tracking-Cookies zu setzen. Da der Dienst rein lokal betrieben wird, bleiben sämtliche Suchanfragen vollständig privat im eigenen Heimnetz.

### Lynis Report (`lynis-report`)
Dieser schlanke Alpine-Container dient als Hilfsdienst, um die Ausgabedatei des Sicherheits-Auditing-Tools Lynis kontinuierlich mitzulesen. Dadurch werden die Sicherheitsberichte des Raspberry Pi als Standard-Logstream bereitgestellt. In Kombination mit Dozzle lassen sich die Ergebnisse der Systemprüfungen somit jederzeit bequem im Browser einsehen.

