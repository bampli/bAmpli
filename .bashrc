# some ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias k='kubectl'
alias kn='kubectl get nodes'
alias kp='kubectl get pods'
alias ks='kubectl get services'
alias kpa='kubectl get pods --all-namespaces'

alias cli='./bampli.sh client'
alias cli-def='./bampli.sh client -i /bampli/gremlin/default.groovy'
alias cli-new='./bampli.sh client -i /bampli/gremlin/bampli.groovy'
alias cli-air='./bampli.sh client -i /bampli/gremlin/janus-inmemory.groovy'
alias cli-d='./bampli.sh client -i /bampli/gremlin/describe.groovy'

alias ej='docker-compose -f elassandra/docker-compose.yml'
alias dsu='docker-compose -f datastax/docker-compose.yml -f datastax/studio.yml up -d'
alias dsd='docker-compose -f datastax/docker-compose.yml -f datastax/studio.yml down'
alias di='docker inspect seed | FINDSTR "IPAddress"'

export KUBECONFIG=k3s.yaml