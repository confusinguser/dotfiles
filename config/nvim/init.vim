let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
	silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
" Plugin Section
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ctrlpvim/ctrlp.vim'
Plug 'morhetz/gruvbox'
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'junegunn/fzf.vim'
Plug 'mfussenegger/nvim-dap'
call plug#end()

runtime lualine/init.lua

set number relativenumber
let mapleader = ','
" Set clipboard to the one used by all other applications
set clipboard+=unnamedplus
" Enable mouse support
set mouse:a
set ignorecase
set smartcase
" always uses spaces instead of tab characters
set expandtab
" Makes typing tabs more consistent
set smarttab
set updatetime=300

" Set color scheme to gruvbox
colorscheme gruvbox
let g:gruvbox_contrast_dark="hard"
set background=dark

" Format on capital F
nmap <silent> F :Format<CR>
" Enables plugins based on filetypes, such as syntax highlighting
filetype plugin on
" Add filetype-dependent indetation
filetype plugin indent on
" Adds folding by syntax
set fdm=syntax
" Inline signcolumn (git gutter)
set signcolumn=number
set scrolloff=6 " Keep n lines below and above the cursor
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

let g:coc_global_extensions = [
                        \ 'coc-rust-analyzer',
                        \ 'coc-pairs',
                        \ 'coc-prettier',
                        \ 'coc-java']

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                        \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)

xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')
"nnoremap <C-f> :Format<CR>

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

nmap <silent> <M-CR> <Plug>(coc-codeaction-cursor)

noremap j h
noremap k j
noremap l k
noremap ö l

" For overriding NetRW, it's ugly yes
autocmd VimEnter * noremap <C-l> <C-y>
noremap <C-k> <C-e>

"map <C-j> <C-k>
"map <C-k> <C-l>

nnoremap <C-S-d> <C-u>

" Exit terminal mode
tnoremap <ESC> <C-\><C-N>

" Window switching
nnoremap <C-w>j <C-w>h
nnoremap <C-w>k <C-w>j
nnoremap <C-w>l <C-w>k
nnoremap <C-w>ö <C-w>l

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
                execute 'h '.expand('<cword>')
        else
                call CocActionAsync('doHover')
        endif
endfunction

" Remap for rename current word
map <F6> <plug>(coc-rename)

nnoremap <C-j> b
nnoremap <C-ö> w

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

noremap <silent><nowait> <RightMouse> <LeftMouse>zo

packadd termdebug
let g:termdebugger="rust-gdb"
