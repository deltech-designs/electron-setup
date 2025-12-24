import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { fileURLToPath } from "url";
import { dirname, resolve } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// https://vitejs.dev/config
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": resolve(__dirname, "./src"),
    },
  },
  build: {
    outDir: ".vite/renderer/main_window",
    rollupOptions: {
      input: {
        main_window: resolve(__dirname, "index.html"),
      },
    },
  },
  server: {
    port: 5173,
  },
});
