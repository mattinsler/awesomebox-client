- git clone [https://github.com/mattinsler/awesomebox](awesomebox) and [https://github.com/mattinsler/awesomebox.node](awesomebox.node)
- npm install in both

```bash
git clone git://git@github.com/mattinsler/awesomebox-client
npm install
rm -rf node_modules/awesomebox
rm -rf node_modules/awesomebox.node
ln -s /path/to/awesomebox node_modules/awesomebox
ln -s /path/to/awesomebox.node node_modules/awesomebox.node
```
