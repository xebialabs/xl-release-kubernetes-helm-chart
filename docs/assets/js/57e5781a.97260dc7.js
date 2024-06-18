"use strict";(self.webpackChunkdocumentation=self.webpackChunkdocumentation||[]).push([[890],{9503:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>a,contentTitle:()=>t,default:()=>h,frontMatter:()=>o,metadata:()=>d,toc:()=>r});var i=s(4848),l=s(8453);const o={sidebar_position:4},t="Assigning Pods to Nodes",d={id:"assigning_pods_to_nodes",title:"Assigning Pods to Nodes",description:"This is internal documentation. This document can be used only if it was recommended by the Support Team.",source:"@site/docs/assigning_pods_to_nodes.md",sourceDirName:".",slug:"/assigning_pods_to_nodes",permalink:"/xl-release-kubernetes-helm-chart/docs/assigning_pods_to_nodes",draft:!1,unlisted:!1,tags:[],version:"current",sidebarPosition:4,frontMatter:{sidebar_position:4},sidebar:"tutorialSidebar",previous:{title:"Make custom configuration for the Release",permalink:"/xl-release-kubernetes-helm-chart/docs/make-custom-configuration"},next:{title:"Manual integration with the Identity Service",permalink:"/xl-release-kubernetes-helm-chart/docs/integrating-with-identity-service"}},a={},r=[{value:"Prerequisites",id:"prerequisites",level:2},{value:"Intro",id:"intro",level:2},{value:"Removing Pods from Specific Node",id:"removing-pods-from-specific-node",level:2},{value:"Assigning XLR Pods to the Specific Nodes",id:"assigning-xlr-pods-to-the-specific-nodes",level:2}];function c(e){const n={admonition:"admonition",code:"code",h1:"h1",h2:"h2",li:"li",ol:"ol",p:"p",pre:"pre",ul:"ul",...(0,l.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(n.h1,{id:"assigning-pods-to-nodes",children:"Assigning Pods to Nodes"}),"\n",(0,i.jsx)(n.admonition,{type:"caution",children:(0,i.jsx)(n.p,{children:"This is internal documentation. This document can be used only if it was recommended by the Support Team."})}),"\n",(0,i.jsx)(n.h2,{id:"prerequisites",children:"Prerequisites"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:"The kubectl command-line tool"}),"\n",(0,i.jsx)(n.li,{children:"Access to a Kubernetes cluster with installed Release"}),"\n"]}),"\n",(0,i.jsx)(n.p,{children:"Tested with:"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:"xl-release 22.2.0-x"}),"\n",(0,i.jsx)(n.li,{children:"xl-cli 10.3.9"}),"\n",(0,i.jsx)(n.li,{children:"Azure cluster"}),"\n"]}),"\n",(0,i.jsx)(n.h2,{id:"intro",children:"Intro"}),"\n",(0,i.jsx)(n.p,{children:"All running pods, deployed with xl-release, have no defined:"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:"pod tolerations"}),"\n",(0,i.jsxs)(n.li,{children:["node labels in the ",(0,i.jsx)(n.code,{children:"nodeSelector"})]}),"\n",(0,i.jsx)(n.li,{children:"node (anti-)affinity"}),"\n"]}),"\n",(0,i.jsx)(n.p,{children:"If you need to apply on pods custom scheduling to the appropriate node you can use following files to change that in your operator package:"}),"\n",(0,i.jsxs)(n.ol,{children:["\n",(0,i.jsxs)(n.li,{children:["\n",(0,i.jsx)(n.p,{children:(0,i.jsx)(n.code,{children:"digitalai-release/kubernetes/dairelease_cr.yaml"})}),"\n",(0,i.jsxs)(n.p,{children:["In the file search all places where is ",(0,i.jsx)(n.code,{children:"tolerations: []"})," or ",(0,i.jsx)(n.code,{children:"nodeSelector: {}"})," and add appropriate values there."]}),"\n"]}),"\n",(0,i.jsxs)(n.li,{children:["\n",(0,i.jsx)(n.p,{children:(0,i.jsx)(n.code,{children:"digitalai-release/kubernetes/template/deployment.yaml"})}),"\n",(0,i.jsxs)(n.p,{children:["In the file add to the path ",(0,i.jsx)(n.code,{children:"spec.template.spec"})," appropriate values with ",(0,i.jsx)(n.code,{children:"tolerations: []"})," or ",(0,i.jsx)(n.code,{children:"nodeSelector: {}"}),"."]}),"\n"]}),"\n"]}),"\n",(0,i.jsx)(n.p,{children:"In next sections we will display few cases that could be applied."}),"\n",(0,i.jsx)(n.h2,{id:"removing-pods-from-specific-node",children:"Removing Pods from Specific Node"}),"\n",(0,i.jsxs)(n.p,{children:["If you need that specific node should not run any xl-release pods, you can apply taint to that node with effect ",(0,i.jsx)(n.code,{children:"NoExecute"}),", for example:"]}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-shell",children:"\u276f kubectl taint nodes node_name key1=value1:NoExecute\n"})}),"\n",(0,i.jsx)(n.p,{children:"All pods that do not have that specific toleration will be immediately removed from nodes with that specific taint."}),"\n",(0,i.jsx)(n.h2,{id:"assigning-xlr-pods-to-the-specific-nodes",children:"Assigning XLR Pods to the Specific Nodes"}),"\n",(0,i.jsx)(n.p,{children:"If you need to have just XLR pods, and no other pod, on the specific node you need to do following, for example:"}),"\n",(0,i.jsxs)(n.ol,{children:["\n",(0,i.jsx)(n.li,{children:"Add to nodes specific taints that will remove all other pods without same tolerations:"}),"\n"]}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-shell",children:"\u276f kubectl taint nodes node_name app=dai:NoExecute\n"})}),"\n",(0,i.jsxs)(n.ol,{start:"2",children:["\n",(0,i.jsx)(n.li,{children:"Add label to the same nodes so XLR when deployed use just that specific nodes:"}),"\n"]}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-shell",children:"\u276f kubectl label nodes node_name app_label=dai_label\n"})}),"\n",(0,i.jsxs)(n.ol,{start:"3",children:["\n",(0,i.jsxs)(n.li,{children:["In the ",(0,i.jsx)(n.code,{children:"digitalai-release/kubernetes/dairelease_cr.yaml"})," update all places with ",(0,i.jsx)(n.code,{children:"tolerations"}),":"]}),"\n"]}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-yaml",children:'tolerations:\n- key: "app"\n  operator: "Equal"\n  value: "dai"\n  effect: "NoExecute"\n'})}),"\n",(0,i.jsxs)(n.p,{children:["And update all places with ",(0,i.jsx)(n.code,{children:"nodeSelector"}),":"]}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-yaml",children:"nodeSelector:\n  app_label: dai_label\n"})}),"\n",(0,i.jsxs)(n.ol,{start:"4",children:["\n",(0,i.jsxs)(n.li,{children:["In the ",(0,i.jsx)(n.code,{children:"digitalai-release/kubernetes/template/deployment.yaml"})," add following lines under ",(0,i.jsx)(n.code,{children:"spec.template.spec"}),":"]}),"\n"]}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-yaml",children:'tolerations:\n- key: "app"\n  operator: "Equal"\n  value: "dai"\n  effect: "NoExecute"\nnodeSelector:\n  app_label: dai_label\n'})})]})}function h(e={}){const{wrapper:n}={...(0,l.R)(),...e.components};return n?(0,i.jsx)(n,{...e,children:(0,i.jsx)(c,{...e})}):c(e)}},8453:(e,n,s)=>{s.d(n,{R:()=>t,x:()=>d});var i=s(6540);const l={},o=i.createContext(l);function t(e){const n=i.useContext(o);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function d(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(l):e.components||l:t(e.components),i.createElement(o.Provider,{value:n},e.children)}}}]);