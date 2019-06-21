import React from 'react';

import ContentPage from 'components/Shared/ContentPage';

export default function AboutPage() {
  return (
    <ContentPage>
      <h1>About Coastal Georgia Floodsight</h1>
      <p>
        Coastal Georgia Floodsight is a 2019 project of the Code for America Fellowship Savannah, GA -- maintained by OpenSavannah.
        Contributors: Casey Herrington, Carl Lewis
      </p>
      <p>
        We keep the map and closure information as up-to-date as possible based
        on the best information currently available, but drivers should pay
        attention to road conditions. If you see water on the road, save
        yourself! Turn around, don't drown!
      </p>
    </ContentPage>
  );
}
