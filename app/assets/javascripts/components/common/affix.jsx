import React from 'react';

const Affix = React.createClass({
  propTypes: {
    offset: React.PropTypes.number,
    className: React.PropTypes.string,
    children: React.PropTypes.node
  },

  getDefaultProps() {
    return { offset: 0 };
  },

  getInitialState() {
    return { affix: false };
  },

  componentDidMount() {
    return window.addEventListener('scroll', this._handleScroll);
  },

  componentWillUnmount() {
    return window.removeEventListener('scroll', this._handleScroll);
  },

  _handleScroll() {
    const { affix } = this.state;
    const { offset } = this.props;
    const scrollTop = document.documentElement.scrollTop || document.body.scrollTop;

    if (!affix && scrollTop >= offset) { this.setState({ affix: true }); }
    if (affix && scrollTop < offset) { return this.setState({ affix: false }); }
  },

  render() {
    const affix = this.state.affix === true ? 'affix' : '';
    let { className } = this.props;
    className += ` ${affix}`;

    return (
      <div className={className}>
        {this.props.children}
      </div>
    );
  }
}
);

export default Affix;
