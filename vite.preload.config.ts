import { defineConfig } from "vite";
import { fileURLToPath } from "url";
import { dirname, resolve } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// https://vitejs.dev/config
export default defineConfig({
  build: {
    sourcemap: true,
    outDir: ".vite/build",
    lib: {
      entry: resolve(__dirname, "src/preload.ts"),
      formats: ["cjs"],
      fileName: () => "[name].js",
    },
    rollupOptions: {
      external: ["electron"],
    },
  },
});
