" utf-8
scriptencoding utf-8
set encoding=utf-8

call plug#begin(stdpath('data') . '/plugged')

" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'lifepillar/vim-solarized8'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'dense-analysis/ale'
Plug 'jparise/vim-graphql'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'morhetz/gruvbox'
" Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'Olical/conjure', {'tag': 'v4.18.0'}
Plug 'Olical/aniseed'
Plug 'guns/vim-sexp', { 'for': 'clojure' }
Plug 'tpope/vim-sexp-mappings-for-regular-people', { 'for': 'clojure' }
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'fatih/vim-go'
Plug 'tomtom/tcomment_vim'
Plug 'hashivim/vim-terraform'

Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }

call plug#end()

" Set the leader key to comma (normally, it's "\")
let mapleader = ","
let maplocalleader=","

" **************** CONVENIENCE MAPPINGS ************  
"
" Ctrl-L recolors the screen when it gets confused.
noremap <c-l> <c-l>:syntax sync fromstart<CR>
inoremap <c-l> <esc><c-l>:syntax sync fromstart<CR>a

" Don't use swap files, they make me cranky
set noswapfile
" Put swapfiles in a central place instead of the current directory.
" Vim will use the first directory that exists.
set directory=~/.vim_swap,~/tmp,/var/tmp,$HOME/Local\ Settings/Temp 

" Same thing for backup files (see `:help backup`)
set backupdir=~/.vim_backup,~/tmp,/var/tmp,$HOME/Local\ Settings/Temp 

" ****************** SCROLLING *********************  
set scrolloff=8      " Number of lines from vertical edge to start scrolling
set sidescrolloff=15 " Number of cols from horizontal edge to start scrolling
set sidescroll=1     " Number of cols to scroll at a time

" ****************** SPLITTING *********************  
set splitright " vsplit makes new pane to the right (not left)
set splitbelow " split  makes new pane below (not above)

" ****************** SEARCHING *********************  
set incsearch     " do incremental searching
set ignorecase    " do case-insensitive searches
set smartcase     " ... unless the search contains upper-case characters
set hlsearch      " highlight all matched terms
" Pressing return clears highlighted search
:nnoremap <CR> :nohlsearch<CR>/<BS>
" Pressing control + return also clears (for use in NERDTree)
:nnoremap <c-CR> :nohlsearch<CR>/<BS>

" ***************** TABS ***************************  
" Usually, you want 2 spaces per tab, so these lines make this the default.
" There are ways to make vi do clever things with tabs in different
" situations, like MS Word can, but I *always* want tab to behave the same way
" -- so I set all three of these tab-related values the same.
" (To overrride these per file type, put commands in .vim/ftplugin/)
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab " insert spaces instead of tab characters
set smarttab  " backspace over a tab will remove a tab's worth of space

" *********** DISPLAYING HIDDEN CHARACTERS *********
" Beautify display of hidden characters (tabs, line breaks, etc).
" (`:set list!` to toggle display; `:help listchars` for info )
" set listchars=nbsp:☠,trail:⋅,tab:▸\ ,eol:¬,extends:❯,precedes:❮
set listchars=trail:⋅,tab:▸\ ,eol:¬,extends:❯,precedes:❮

" ************ CtrlP (File Finder) ****************
" - Pressing <control + p> starts it.
" - <ctrl + j/k> moves between matches.
" - Enter opens. <ctrl + t> opens in same tab (with config below).
" - ctrl+f changes modes. MRU means 'Most Recently Used'. 
" - <ctrl + r> toggles regexp/fuzzy search; regexp is also nice for exact filenames
"
" Open a single file in a new tab by default
let g:ctrlp_prompt_mappings = {'AcceptSelection("e")': ['<c-t>'], 'AcceptSelection("t")': ['<cr>', '2-LeftMouse'], }
" Open new files in a new tab
let g:ctrlp_open_new_file = 't'
" Open multiple files in new tabs and jump to the first one
let g:ctrlp_open_multiple_files = 'tj'

let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'


" From Nathan's section of the gvim
set textwidth=78

"** When indenting in visual mode, return to visual mode **
" indent with > or tab
vmap > >gv
vmap <tab> >gv
" outdent with < or shift-tab
vmap < <gv
vmap <S-Tab> <gv
" Shift-tab in insert mode is a backspace (unindent)
imap <S-Tab> <BS>

" Control+h produces a hashrocket
imap <C-h> <Space>=><Space>

" Always show line numbers
set number

" Move lines up and down
nmap <C-J> :m +1 <CR>
nmap <C-K> :m -2 <CR>

" Duplicate a selection
" Visual mode: D
vmap D y'>p

" Visually select the text that was last edited/pasted with 'gV'
" (This is based on the standard 'gv', which repeats the last selection)
nnoremap <expr> gV '`[' . strpart(getregtype(), 0, 1) . '`]'

" Inserts the path of the currently edited file into a command
" Command mode: Ctrl+P
cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=1
let g:syntastic_java_javac_config_file_enabled=1

let g:vim_markdown_folding_disabled=1

let g:jsx_ext_required = 0 " Allow JSX in normal JS files

set timeoutlen=1000 ttimeoutlen=0
let g:ale_completion_enabled = 1

set t_Co=256
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
set background=dark
colorscheme gruvbox
let g:ale_fixers = {
\   'javascript': ['eslint', 'prettier'],
\   'typescript': ['eslint', 'prettier'],
\   'javascriptreact': ['eslint', 'prettier'],
\   'typescriptreact': ['eslint', 'prettier'],
\}
let g:ale_fix_on_save=0
let g:ale_floating_preview = 1
" In ~/.vim/vimrc, or somewhere similar.
"let g:ale_linter_aliases = {
"\   'jsx': ['css', 'javascript'],
"\   'tsx': ['css', 'typescript'],
"\}
"let g:ale_linters = {
"\   'jsx': ['prettier', 'eslint'],
"\   'tsx': ['prettier', 'eslint'],
"\}

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fa <cmd>Telescope find_files hidden=true<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Using Lua functions
" nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
" nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
" nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
" nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

" MDK mappings
set guicursor=i:block
map <leader>gd <cmd>ALEGoToDefinition<cr>
map <leader>h <cmd>ALEHover<cr>
map <leader>an <cmd>ALENext<cr>
map <leader>af <cmd>ALEFindReferences<cr>
inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" : "\<TAB>"
