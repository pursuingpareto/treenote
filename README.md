# TreeNote
TreeNote is my mobile version of [Gingko](https://gingkoapp.com/app), my favorite note-taking app for many purposes.

It's called tree note because the underlying structure is a tree and I wasn't feeling clever.

```json
{
	"text": "Chapter 1",
	"children" : {
		[
			{"text" : "Chapter 1, part 1", "children" : []},
			{"text" : "Chapter 1, part 2", "children" : []}
		]
	}
}
```

I'm planning to open source the `PagedTableViewController` as it's own component but need to make some improvements, most notably to the API. 