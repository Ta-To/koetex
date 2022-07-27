WORK IN PROGRESS

run sample on server

`iex --name "server@127.0.0.1" -S mix`

```
Koetex.Samples.OneMax.start()
```

run sample on client

`iex --name "node@127.0.0.1" -S mix`

```
Node.connect(:"server@127.0.0.1")
Koetex.Samples.OneMax.start_as_client()
Koetex.Samples.OneMax.spawn_indiv()
```


# Koetex

Koetex is a Genetic Algorithm library run parallel.

For why:

- GA is interesting approch to solve some optimization problems.
- And... my elixir exercise.

For your information:

- Maybe what you're looking for is [TODO]().

## Versions

This has been confirmed to work under the following conditions.

```
$ elixir -v
TODO
```

## Installation

```
def deps do
  [
    {:koete, "~> 0.1.0"}
  ]
end
```

Documentation is [here](https://hexdocs.pm/koete).
Documentation is generated with [ExDoc](https://github.com/elixir-lang/ex_doc).
and published on [HexDocs](https://hexdocs.pm).


## Usage

### Sample problem

TODO

### Your problem (Customize)

TODO

## License

Copyright 2022 ta.to.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
