// The four calls the app makes. Every answer is JSON; `ok` tells success from a
// 422 whose body carries `errors`. Money never gets computed here — the server
// prices, the client sends ids, sizes, quantities and codes.
async function request(method, path, body) {
  const token = document.querySelector('meta[name="csrf-token"]')?.content ?? ''
  const response = await fetch(path, {
    method,
    headers: { 'Content-Type': 'application/json', Accept: 'application/json', 'X-CSRF-Token': token },
    body: body === undefined ? undefined : JSON.stringify(body),
  })
  const data = await response.json().catch(() => ({ errors: [`Der Server hat mit ${response.status} geantwortet.`] }))
  return { ok: response.ok, status: response.status, data }
}

export const api = {
  menu: () => request('GET', '/menu'),
  quote: (cart) => request('POST', '/quotes', cart),
  placeOrder: (order) => request('POST', '/orders', order),
}
