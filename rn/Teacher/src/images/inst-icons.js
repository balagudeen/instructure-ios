//
// Copyright (C) 2018-present Instructure, Inc.
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

// DO NOT EDIT: this file was generated by build_icons.js
// @flow

export type InstIconName =
  'alerts' | 'announcement' | 'arrowOpenLeft' | 'arrowOpenRight' | 'assignment' | 'box' |
  'calendarMonth' | 'check' | 'complete' | 'courses' | 'dashboard' | 'discussion' | 'document' |
  'email' | 'empty' | 'folder' | 'gradebook' | 'group' | 'hamburger' | 'highlighter' |
  'instructure' | 'link' | 'lock' | 'lti' | 'marker' | 'miniArrowDown' | 'miniArrowUp' | 'module' |
  'more' | 'no' | 'outcomes' | 'paint' | 'prerequisite' | 'question' | 'quiz' | 'refresh' |
  'rubric' | 'settings' | 'star' | 'strikethrough' | 'text' | 'trash' | 'trouble' | 'unlock' |
  'user' | 'x'

export default function icon (name: InstIconName, type: 'line' | 'solid' = 'line') {
  return { uri: `${name}${type[0].toUpperCase()}${type.slice(1)}` }
}
