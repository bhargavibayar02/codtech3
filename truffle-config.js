module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545, // default port for Ganache GUI
      network_id: "*"
    }
  },
  compilers: {
    solc: {
      version: "0.8.0"
    }
  }
};
