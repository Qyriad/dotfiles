import { defineConfig } from "vite";
import { consoleForwardPlugin } from "vite-console-forward-plugin";

export default defineConfig({
	build: {
		sourcemap: 'inline',
		minify: false,
	},
	css: {
		devSourcemap: true,
	},
	clearScreen: false,
	plugins: [
		consoleForwardPlugin({
			// Enable console forwarding (default: true in dev mode)
			enabled: true,

			// Custom API endpoint (default: '/api/debug/client-logs')
			endpoint: "/api/debug/client-logs",

			// Which console levels to forward (default: all)
			levels: ["log", "warn", "error", "info", "debug"],
		}),
	],
});
