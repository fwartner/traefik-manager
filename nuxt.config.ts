// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-05-15',
  devtools: { enabled: process.env.NODE_ENV === 'development' },
  modules: ['@nuxtjs/tailwindcss'],
  css: ['~/assets/css/main.css'],
  
  // Production optimizations
  nitro: {
    compressPublicAssets: true,
    minify: true
  },
  
  // Runtime configuration
  runtimeConfig: {
    // Private keys (only available on server-side)
    traefikConfigDir: process.env.TRAEFIK_CONFIG_DIR || '/etc/traefik/dynamic',
    
    // Public keys (exposed to client-side)
    public: {
      appName: 'Traefik Manager',
      version: process.env.npm_package_version || '1.0.0'
    }
  },
  
  // App configuration
  app: {
    head: {
      title: 'Traefik Manager',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Web interface for managing Traefik configurations' },
        { name: 'author', content: 'Florian Wartner' }
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
      ]
    }
  },
  
  // Server-side rendering
  ssr: true,
  
  // TypeScript configuration
  typescript: {
    strict: true,
    typeCheck: process.env.NODE_ENV === 'development'
  }
})


