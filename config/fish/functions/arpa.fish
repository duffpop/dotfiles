function arpa --wraps=arp\ -a\ \|\ awk\ \'\{print\ \$4\}\'\ \|\ xargs\ -I\ \{\}\ sh\ -c\ \'echo\ \{\}\;\ sleep\ 1\;\ curl\ -s\ https://api.macvendors.com/\{\}\' --description alias\ arpa=arp\ -a\ \|\ awk\ \'\{print\ \$4\}\'\ \|\ xargs\ -I\ \{\}\ sh\ -c\ \'echo\ \{\}\;\ sleep\ 1\;\ curl\ -s\ https://api.macvendors.com/\{\}\'
  arp -a | awk '{print $4}' | xargs -I {} sh -c 'echo {}; sleep 1; curl -s https://api.macvendors.com/{}' $argv
end
