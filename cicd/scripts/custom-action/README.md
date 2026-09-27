# Custom Greeting Action

A JavaScript GitHub Action that greets someone and outputs the time of the greeting.
The live action is published from [Irum-F/irum-custom-actions](https://github.com/Irum-F/irum-custom-actions). This is a copy for the portfolio.

`node_modules/` is not copied here. Run `npm install` to restore it.

## Usage

```yaml
- name: hello world custom action
  uses: Irum-F/irum-custom-actions@main
  with:
    who-to-greet: 'Hello, its me, Irum!'
```

| Input | Required | Description |
|---|---|---|
| `who-to-greet` | yes | Who to greet |

| Output | Description |
|---|---|
| `time` | The time greeted |
