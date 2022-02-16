import React from 'react';
import clsx from 'clsx';
import styles from './HomepageFeatures.module.css';

const FeatureList = [
  {
    title: 'Easy to Use',
    Svg: require('../../static/img/1.svg').default,
    description: (
      <>
          Release Kubernetes Helm Chart was designed from the ground up to be easy in use to spin up
        Release cluster setup.
      </>
    ),
  },
  {
    title: 'Focus on What Matters',
    Svg: require('../../static/img/2.svg').default,
    description: (
      <>
          Release Kubernetes Helm Chart takes a burden of configuring the setup for you.
      </>
    ),
  },
  {
    title: 'Backed by Digital.ai',
    Svg: require('../../static/img/3.svg').default,
    description: (
      <>
          Digital.ai team to help you with that.
      </>
    ),
  },
];

function Feature({Svg, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} alt={title} />
      </div>
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
