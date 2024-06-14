const {themes} = require('prism-react-renderer');
const lightCodeTheme = themes.github;
const darkCodeTheme = themes.dracula;

module.exports = {
  title: 'Release Kubernetes Helm Chart',
  tagline: '',
  url: 'https://xebialabs.github.io',
  baseUrl: '/xl-release-kubernetes-helm-chart/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/digital_ai_deploy.svg',
  organizationName: 'Digital.ai',
  projectName: 'xl-release-kubernetes-helm-chart',
  themeConfig: {
    navbar: {
      title: 'Release Kubernetes Helm Chart',
      logo: {
        alt: 'Release Kubernetes Helm Chart Digital.ai',
        src: 'img/digital_ai_deploy.svg',
      },
      items: [
        {
          type: 'doc',
          docId: 'intro',
          position: 'left',
          label: 'Tutorial',
        },

        {
          href: 'https://github.com/xebialabs/xl-release-kubernetes-helm-chart',
          label: 'GitHub',
          position: 'right',
        }
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Tutorial',
              to: '/docs/intro',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/xebialabs/xl-release-kubernetes-helm-chart',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Release Kubernetes Helm Chart Digital.ai`,
    },
    prism: {
      theme: lightCodeTheme,
      darkTheme: darkCodeTheme,
    },
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js')
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
};
