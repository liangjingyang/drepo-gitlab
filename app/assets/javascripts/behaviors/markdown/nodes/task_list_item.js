import { Node } from 'tiptap'

export default class TaskListItemNode extends Node {
  get name() {
    return 'task_list_item'
  }

  get schema() {
    return {
      attrs: {
        done: {
          default: false,
        },
      },
      defining: true,
      draggable: false,
      content: 'paragraph block*',
      parseDOM: [
        {
          priority: 51,
          tag: 'li.task-list-item',
          getAttrs: el => {
            const checkbox = el.querySelector('input[type=checkbox].task-list-item-checkbox');
            return { done: checkbox && checkbox.checked };
          },
        }
      ],
      toDOM(node) {
        return ['li', { class: 'task-list-item' },
          ['input', { type: 'checkbox', class: 'task-list-item-checkbox', checked: node.attrs.done }],
          ['div', { class: 'todo-content' }, 0],
        ]
      },
    }
  }

  toMarkdown(state, node) {
    state.write(`[${node.attrs.done ? 'x' : ' '}] `);
    state.renderContent(node);
  }
}
