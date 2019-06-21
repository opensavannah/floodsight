import React, { Component } from 'react';
import PropTypes from 'prop-types';

import CtxFloodsLogoDarkSvg from 'images/floodsight-coastalga.png';
import './Header.css';

export default class Header extends Component {
  static propTypes = {
    location: PropTypes.object.isRequired,
    title: PropTypes.string,
    children: PropTypes.node.isRequired,
  };

  componentDidMount() {
    document.title = `Savannah Floods - Turn Around, Do Not Drown`;
  }

  render() {
    return (
      <div className="Header">
        <div className="Header__main">
          <h1 className="Header__logo">
            <img
              src={CtxFloodsLogoDarkSvg}
              alt="SAVfloods | Savannah Floods"
            />
            <div className="Header__title">{this.props.title}</div>
          </h1>
          <ul className="Header__tabs">{this.props.children}</ul>
        </div>
      </div>
    );
  }
}
