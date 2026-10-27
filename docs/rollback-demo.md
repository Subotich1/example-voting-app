# Rollback demo (Capstone 1, Step 5)

Goal: ship a bad release on purpose, show it failing, then recover with `helm rollback`.

## 0. Starting point
A good release is running (deployed by the pipeline):

```bash
helm history voting-app -n voting-app
kubectl get pods -n voting-app
```

Open the vote URL (`kubectl get svc vote -n voting-app`) and cast a vote.

## 1. Ship a bad release
Point the vote service at an image tag that does not exist:

```bash
helm upgrade voting-app helm/voting-app -n voting-app \
  --reuse-values \
  --set image.tag=this-tag-does-not-exist \
  --wait --timeout 2m
```

What the audience sees:
- The command fails after the timeout (`context deadline exceeded`)
- `kubectl get pods -n voting-app` shows new pods stuck in `ImagePullBackOff`
- `helm history voting-app -n voting-app` shows the new revision as `failed`

The old pods keep serving traffic while the new ones fail their readiness checks,
so users are not affected. This is why readiness probes matter.

## 2. Roll back

```bash
helm history voting-app -n voting-app          # find the last good REVISION
helm rollback voting-app <REVISION> -n voting-app --wait
kubectl get pods -n voting-app                  # all Running again
```

`helm history` now shows a new revision whose description is `Rollback to <REVISION>`.

## 3. Talking points for Q&A
- Every release is versioned, so rollback is one command and takes seconds.
- Images are tagged with the commit SHA, so each revision maps to an exact commit.
- `helm upgrade --atomic` would roll back automatically; we run it manually here to show the process.
