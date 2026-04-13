const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute("content")

export async function apiFetch(path, options = {}) {
  const headers = {
    "Content-Type": "application/json",
    "X-CSRF-Token": csrfToken(),
    ...(options.headers || {}),
  }

  const response = await fetch(path, {
    ...options,
    headers,
  })

  if (!response.ok) {
    let message = `Request failed: ${response.status}`

    try {
      const json = await response.json()
      if (json.errors) {
        message = json.errors.join("\n")
      }
    } catch (_error) {
      // noop
    }

    throw new Error(message)
  }

  if (response.status === 204) {
    return null
  }

  return response.json()
}
