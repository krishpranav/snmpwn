# snmpwn
SNMPv3 user enumerator and attack tool made in ruby

[![forthebadge](https://forthebadge.com/images/badges/made-with-ruby.svg)](https://forthebadge.com)

# Installation
```
git clone https://github.com/krishpranav/snmpwn
cd snmpwn
bundle install
./snmpwn.rb
```

# Usage
```
./snmpwn.rb --hosts hosts.txt --users users.txt --passlist passwords.txt --enclist passwords.txt
```

## What does it do?
- Checks that the hosts you provide are responding to SNMP requests.
- Enumerates SNMP users by testing each in the list you provide. Think user brute forcing.
- Attacks the server with the enumerated accounts and your list of passwords and encryption passwords. No need to attack the entire list of users, only live accounts.
- Attacks all the different protocol types:
	- No auth no encryption (noauth)
    - Authentication, no encryption (authnopriv)
    - Authentication and encryption (All types supported, MD5, SHA, DES, AES) - (authpriv)
