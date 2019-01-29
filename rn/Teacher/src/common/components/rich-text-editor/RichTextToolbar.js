//
// Copyright (C) 2017-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/* @flow */

import React, { Component } from 'react'
import {
  StyleSheet,
  TouchableHighlight,
  Image,
  ScrollView,
  View,
  LayoutAnimation,
  NativeModules,
  I18nManager,
} from 'react-native'

import { ColorPicker } from './'
import images from '../../../images'
import colors from '../../colors'
import i18n from 'format-message'

type Props = {
  active?: string[],
  setBold?: () => void,
  setItalic?: () => void,
  setTextColor?: (color: string) => void,
  setUnorderedList?: () => void,
  setOrderedList?: () => void,
  insertLink?: () => void,
  insertImage?: ?(() => void),
  onTappedDone?: () => void,
  onColorPickerShown?: (shown: boolean) => void,
}

type State = {
  colorPickerVisible: boolean,
}

type Item = {
  image: string,
  action: string,
  accessibilityLabel: string,
  flipImageForRTL: boolean,
}

function item (image: string, action: string, accessibilityLabel: string, flipImageForRTL?: boolean = false): Item {
  return { image, action, accessibilityLabel, flipImageForRTL }
}

const ColorPickerAnimation = {
  duration: 200,
  create: {
    type: LayoutAnimation.Types.linear,
    property: LayoutAnimation.Properties.opacity,
    springDamping: 0.7,
  },
  update: {
    type: LayoutAnimation.Types.spring,
    springDamping: 0.7,
  },
}

const { NativeAccessibility } = NativeModules

export default class RichTextToolbar extends Component<Props, State> {
  state: State = {
    colorPickerVisible: false,
  }

  render () {
    const ITEMS = [
      item('undo', 'undo', i18n('Undo'), true),
      item('redo', 'redo', i18n('Redo'), true),
      item('bold', 'setBold', i18n('Bold')),
      item('italic', 'setItalic', i18n('Italic')),
      item('textColor', 'setTextColor', i18n('Text Color')),
      item('unorderedList', 'setUnorderedList', i18n('Unordered List'), true),
      item('orderedList', 'setOrderedList', i18n('Ordered List'), true),
      item('link', 'insertLink', i18n('Insert Link')),
      item('embedImage', 'insertImage', i18n('Insert Image')),
    ]

    return (
      <View style={styles.container}>
        { this.state.colorPickerVisible && this.props.setTextColor &&
          <ColorPicker pickedColor={this._pickColor} />
        }
        <View style={styles.itemsContainer}>
          <ScrollView horizontal={true}>
            {ITEMS.filter((item) => this.props[item.action]).map((item) => {
              return (
                <TouchableHighlight
                  style={styles.item}
                  onPress={this._actionForItem(item)}
                  underlayColor={colors.grey1}
                  key={item.image}
                  testID={`rich-text-toolbar-item-${item.image}`}
                  accessibilityLabel={item.accessibilityLabel}
                  accessibilityTraits={['button']}
                >
                  {this._renderItem(item)}
                </TouchableHighlight>
              )
            })}
          </ScrollView>
        </View>
      </View>
    )
  }

  _renderItem ({ image, flipImageForRTL }: Item) {
    switch (image) {
      case 'textColor':
        const textColorKey = this.props.active && this.props.active.find((s) => s.startsWith('textColor'))
        const textColor = textColorKey && textColorKey.split(':')[1]
        const style = {
          backgroundColor: textColor || 'black',
          borderWidth: textColor && isWhite(textColor) ? 1 : 0,
          borderColor: textColor && isWhite(textColor) ? '#E6E9EA' : 'transparent',
        }
        return <View style={[styles.textColor, style]} />
      default:
        const isActive = (this.props.active || []).includes(image) && images.rce.active[image]
        const icon = images.rce[image]
        const tintColor = isActive ? colors.primaryBrandColor : colors.secondaryButton
        const transform = [{ scaleX: I18nManager.isRTL && flipImageForRTL ? -1 : 1 }]
        return <Image source={icon} style={{ tintColor, transform }} />
    }
  }

  _toggleColorPicker = () => {
    const shown = !this.state.colorPickerVisible
    LayoutAnimation.configureNext(ColorPickerAnimation, () => {
      if (this.props.onColorPickerShown) {
        this.props.onColorPickerShown(shown)
      }
    })
    this.setState({ colorPickerVisible: shown })
    setTimeout(function () { NativeAccessibility.focusElement('color-picker.options') }, 500)
  }

  _pickColor = (color: string) => {
    this.setState({ colorPickerVisible: false })
    this.props.setTextColor && this.props.setTextColor(color)
  }

  _actionForItem = (item: Item): Function => {
    switch (item.action) {
      case 'setTextColor':
        return this._toggleColorPicker
      default:
        return this.props[item.action]
    }
  }
}

function isWhite (color: string): boolean {
  const whites = ['white', 'rgb(255,255,255)']
  return whites.includes(color.replace(/[ ]/g, ''))
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'column',
    backgroundColor: 'white',
    justifyContent: 'flex-end',
  },
  itemsContainer: {
    borderTopWidth: 1,
    borderTopColor: '#C7CDD1',
    backgroundColor: 'white',
  },
  item: {
    width: 50,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 8,
  },
  textColor: {
    width: 26,
    height: 26,
    borderRadius: 13,
  },
})
