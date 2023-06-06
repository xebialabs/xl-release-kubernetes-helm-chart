"use strict";(self.webpackChunkdocumentation=self.webpackChunkdocumentation||[]).push([[831],{3905:function(e,t,n){n.d(t,{Zo:function(){return s},kt:function(){return d}});var a=n(7294);function r(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function i(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);t&&(a=a.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,a)}return n}function o(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?i(Object(n),!0).forEach((function(t){r(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):i(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,a,r=function(e,t){if(null==e)return{};var n,a,r={},i=Object.keys(e);for(a=0;a<i.length;a++)n=i[a],t.indexOf(n)>=0||(r[n]=e[n]);return r}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(a=0;a<i.length;a++)n=i[a],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(r[n]=e[n])}return r}var c=a.createContext({}),p=function(e){var t=a.useContext(c),n=t;return e&&(n="function"==typeof e?e(t):o(o({},t),e)),n},s=function(e){var t=p(e.components);return a.createElement(c.Provider,{value:t},e.children)},u={inlineCode:"code",wrapper:function(e){var t=e.children;return a.createElement(a.Fragment,{},t)}},m=a.forwardRef((function(e,t){var n=e.components,r=e.mdxType,i=e.originalType,c=e.parentName,s=l(e,["components","mdxType","originalType","parentName"]),m=p(n),d=r,f=m["".concat(c,".").concat(d)]||m[d]||u[d]||i;return n?a.createElement(f,o(o({ref:t},s),{},{components:n})):a.createElement(f,o({ref:t},s))}));function d(e,t){var n=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var i=n.length,o=new Array(i);o[0]=m;var l={};for(var c in t)hasOwnProperty.call(t,c)&&(l[c]=t[c]);l.originalType=e,l.mdxType="string"==typeof e?e:r,o[1]=l;for(var p=2;p<i;p++)o[p]=n[p];return a.createElement.apply(null,o)}return a.createElement.apply(null,n)}m.displayName="MDXCreateElement"},614:function(e,t,n){n.r(t),n.d(t,{frontMatter:function(){return l},contentTitle:function(){return c},metadata:function(){return p},toc:function(){return s},default:function(){return m}});var a=n(7462),r=n(3366),i=(n(7294),n(3905)),o=["components"],l={sidebar_position:3},c=void 0,p={unversionedId:"make-custom-configuration",id:"make-custom-configuration",isDocsHomePage:!1,title:"make-custom-configuration",description:"This is internal documentation. This document can be used only if it was recommended by the Support Team.",source:"@site/docs/make-custom-configuration.md",sourceDirName:".",slug:"/make-custom-configuration",permalink:"/xl-release-kubernetes-helm-chart/docs/make-custom-configuration",tags:[],version:"current",sidebarPosition:3,frontMatter:{sidebar_position:3},sidebar:"tutorialSidebar",previous:{title:"building-operator-image",permalink:"/xl-release-kubernetes-helm-chart/docs/building-operator-image"},next:{title:"assigning_pods_to_nodes",permalink:"/xl-release-kubernetes-helm-chart/docs/assigning_pods_to_nodes"}},s=[{value:"Requirements",id:"requirements",children:[],level:2},{value:"Steps",id:"steps",children:[],level:2}],u={toc:s};function m(e){var t=e.components,n=(0,r.Z)(e,o);return(0,i.kt)("wrapper",(0,a.Z)({},u,n,{components:t,mdxType:"MDXLayout"}),(0,i.kt)("div",{className:"admonition admonition-caution alert alert--warning"},(0,i.kt)("div",{parentName:"div",className:"admonition-heading"},(0,i.kt)("h5",{parentName:"div"},(0,i.kt)("span",{parentName:"h5",className:"admonition-icon"},(0,i.kt)("svg",{parentName:"span",xmlns:"http://www.w3.org/2000/svg",width:"16",height:"16",viewBox:"0 0 16 16"},(0,i.kt)("path",{parentName:"svg",fillRule:"evenodd",d:"M8.893 1.5c-.183-.31-.52-.5-.887-.5s-.703.19-.886.5L.138 13.499a.98.98 0 0 0 0 1.001c.193.31.53.501.886.501h13.964c.367 0 .704-.19.877-.5a1.03 1.03 0 0 0 .01-1.002L8.893 1.5zm.133 11.497H6.987v-2.003h2.039v2.003zm0-3.004H6.987V5.987h2.039v4.006z"}))),"caution")),(0,i.kt)("div",{parentName:"div",className:"admonition-content"},(0,i.kt)("p",{parentName:"div"},"This is internal documentation. This document can be used only if it was recommended by the Support Team."))),(0,i.kt)("h1",{id:"make-custom-configuration-for-the-release"},"Make custom configuration for the Release"),(0,i.kt)("h2",{id:"requirements"},"Requirements"),(0,i.kt)("ul",null,(0,i.kt)("li",{parentName:"ul"},"Running Release installation on k8s cluster"),(0,i.kt)("li",{parentName:"ul"},(0,i.kt)("inlineCode",{parentName:"li"},"kubectl")," connected to the cluster"),(0,i.kt)("li",{parentName:"ul"},"Release operator version above following:",(0,i.kt)("ul",{parentName:"li"},(0,i.kt)("li",{parentName:"ul"},"10.2.18"),(0,i.kt)("li",{parentName:"ul"},"10.3.16"),(0,i.kt)("li",{parentName:"ul"},"22.0.8"),(0,i.kt)("li",{parentName:"ul"},"22.1.6"),(0,i.kt)("li",{parentName:"ul"},"22.2.2")))),(0,i.kt)("h2",{id:"steps"},"Steps"),(0,i.kt)("ol",null,(0,i.kt)("li",{parentName:"ol"},(0,i.kt)("p",{parentName:"li"},"Download current template configuration file that exists on you Release pod that is running.\nIt is in the ",(0,i.kt)("inlineCode",{parentName:"p"},"/opt/xebialabs/xl-release-server/default-conf/xl-release.conf.template")," "),(0,i.kt)("pre",{parentName:"li"},(0,i.kt)("code",{parentName:"pre"},"For example:\n```shell\nkubectl cp digitalai/dai-xlr-digitalai-release-0:/opt/xebialabs/xl-release-server/default-conf/xl-release.conf.template .\n```\n"))),(0,i.kt)("li",{parentName:"ol"},(0,i.kt)("p",{parentName:"li"},"Update the CR file or CR on the cluster"),(0,i.kt)("p",{parentName:"li"},"Use that file to update your CR file under ",(0,i.kt)("inlineCode",{parentName:"p"},"spec.release.configurationManagement.configuration.scriptData")," path. Add there the content of the ",(0,i.kt)("inlineCode",{parentName:"p"},"xl-release.conf.template")," file under the ",(0,i.kt)("inlineCode",{parentName:"p"},"xl-release.conf.template")," key."),(0,i.kt)("p",{parentName:"li"},"Also update the script under the ",(0,i.kt)("inlineCode",{parentName:"p"},"spec.release.configurationManagement.configuration.script")," path. Add there "),(0,i.kt)("p",{parentName:"li"},"For example:"),(0,i.kt)("pre",{parentName:"li"},(0,i.kt)("code",{parentName:"pre",className:"language-yaml"},'...\n        script: |-\n          ...\n          cp /opt/xebialabs/xl-release-server/xlr-configuration-management/xl-release.conf.template /opt/xebialabs/xl-release-server/default-conf/xl-release.conf.template && echo "Changing the xl-release.conf.template";\n        scriptData:\n          ...\n          xl-release.conf.template: |-\n            xl {\n              ...\n            }\n'))),(0,i.kt)("li",{parentName:"ol"},(0,i.kt)("p",{parentName:"li"},"If you have oidc enabled, in that case disable it. Because the changes that are from there will conflict with your changes in the ",(0,i.kt)("inlineCode",{parentName:"p"},"xl-release.conf.template")," file."),(0,i.kt)("p",{parentName:"li"},"Just in CR file put ",(0,i.kt)("inlineCode",{parentName:"p"},"spec.oidc.enabled: false"),".")),(0,i.kt)("li",{parentName:"ol"},(0,i.kt)("p",{parentName:"li"},"Save and apply changes from the CR file."))))}m.isMDXComponent=!0}}]);