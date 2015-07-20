define heka::encoder::sandboxencoder (
  # Common Sandbox Parameters
  $script_type       = 'lua',
  $filename,
  $preserve_data     = undef,
  $memory_limit      = undef,
  $instruction_limit = undef,
  $output_limit      = undef,
  $module_directory  = undef,
  # decoder specific
  $config            = undef,
) {
  heka::snippet { $name: content => template("${module_name}/encoder/sandboxencoder.toml.erb"), }
}