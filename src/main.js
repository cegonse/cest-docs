const hide = (elem) => document.querySelector(elem).classList.add('hidden')

const show = (elem) => document.querySelector(elem).classList.remove('hidden')

const get = (elem) => document.querySelector(elem)

window.addEventListener('load', () => {
    get('#documentation-button').addEventListener('click', () => {
        hide('#description-block')
        show('#documentation-block')
    })
})
