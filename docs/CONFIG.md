# Configuration

If your command will make use of user configuration, you can use the following to load it:

```bash
source "$DOROTHY/sources/config.sh"
config_file="$(get_dorothy_config 'filename.extension')"  # replace filename.extension with what will be sourced
```
