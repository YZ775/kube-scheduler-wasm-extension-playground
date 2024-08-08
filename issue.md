<!-- Please use this template while reporting a bug and provide as much info as possible. Not doing so may result in your bug not being addressed in a timely manner. Thanks!

If the matter is security related, please disclose it privately via https://kubernetes.io/security/
-->

**What happened**:

When I tried to run the scheduler, I found the scheduler does not accepts parameters other than `--config`.

I think this is because flag package is used in config.go even though the kube-scheduler plugin framework uses the cobra package.

In order to handle this, I re-write the code to define flags before `NewSchedulerCommand`.
Below is the code I modified. It works well in my local environment.

```go  main.go
var rootCmd = cobra.Command{
	Run: func(cmd *cobra.Command, args []string) {
		configFile := cmd.Flag("config").Value.String()
		pluginNames, err := getWasmPluginsFromConfig(configFile)
		if err != nil {
			fmt.Fprintf(os.Stderr, "failed to get wasm plugins from config: %v\n", err)
			os.Exit(1)
		}

		opt := []app.Option{}
		for _, pluginName := range pluginNames {
			opt = append(opt, app.WithPlugin(pluginName, wasm.PluginFactory(pluginName)))
		}
		command := app.NewSchedulerCommand(opt...)
		command.Execute()
	},
	SilenceUsage: true,
}

func main() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	opts := options.NewOptions()
	nfs := opts.Flags
	verflag.AddFlags(nfs.FlagSet("global"))
	globalflag.AddGlobalFlags(nfs.FlagSet("global"), rootCmd.Name(), logs.SkipLoggingConfigurationFlags())
	fs := rootCmd.Flags()
	for _, f := range nfs.FlagSets {
		fs.AddFlagSet(f)
	}
}
```

Do you have any plans to support parameters other than `--config`?

**What you expected to happen**:

I want to pass parameters to the scheduler in order to run in real Kubernetes cluster.

**How to reproduce it (as minimally and precisely as possible)**:
```console
$ go build -o kube-scheduler ./cmd/scheduler
```

```console
$ ./kube-scheduler -h
Usage of ./kube-scheduler:
  -config string
```

```console
$ ./kube-scheduler --config=config.yaml -v 10
flag provided but not defined: -v
Usage of ./kube-scheduler:
  -config string
```
**Anything else we need to know?**:

**Environment**:

- Kubernetes version (use `kubectl version`):
- kube-scheduler-wasm-extension version (use `git describe --tags --dirty --always`):
- Cloud provider or hardware configuration:
- OS (e.g: `cat /etc/os-release`):
- Kernel (e.g. `uname -a`):
- Install tools:
- Others:
