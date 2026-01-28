module.exports = {
  apps: [
    {
      name: "sufism-backend",
      script: "./dist/server.js",
      instances: 1, // Use 1 instance for now to avoid potential issues
      exec_mode: "fork",
      env: {
        NODE_ENV: "production",
        PORT: 8001
      },
      env_production: {
        NODE_ENV: "production",
        PORT: process.env.PORT || 8001
      },
      error_file: "./logs/app-err.log",
      out_file: "./logs/app-out.log",
      log_file: "./logs/app-combined.log",
      time: true,
      max_restarts: 10,
      min_uptime: "10s",
      max_memory_restart: "1G",
      node_args: ["--experimental-modules"],
      watch: false
    }
  ]
};
