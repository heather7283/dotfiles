# ref: https://github.com/monero-project/monero/issues/9878

config_dir="${XDG_CONFIG_HOME:?}/bitmonero"
state_dir="${XDG_STATE_HOME:?}/bitmonero"
data_dir="${XDG_DATA_HOME:?}/bitmonero"
wallets_dir="${data_dir}/wallets"

mkdir -p "$config_dir" "$state_dir" "$data_dir" "$wallets_dir" || die 'mkdir failed'

set -- \
    --log-file "${state_dir}/monero-wallet-cli.log" \
    --config-file "${config_dir}/monero-wallet-cli.conf" \
    "$@"

