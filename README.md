### `nomad-pack` CLIs

```bash
nomad-pack registry list
nomad-pack registry add example https://github.com/gkspranger/nomad-fun --ref=simple
nomad-pack render blueapp --ref=simple --registry=example
nomad-pack plan blueapp --ref=simple --registry=example
```

to develop locally, CD into pack you are working on

```bash
nomad-pack render .

nomad-pack info .

nomad-pack render . --var=enable_canary_update=true --var=count=4
```


```bash
# prom query to get request count every 10s
increase(flask_http_request_total[10s])
```
