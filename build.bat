stylua src -f .meta/.stylua.toml
selene src --config .meta/selene.toml
darklua process src/init.lua dist.lua -c .meta/.darklua.json