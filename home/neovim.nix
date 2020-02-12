# todo: clean this whole file up. Been doing lots of hacking.
{ pkgs, ... }:

let
  old_dots = import ./_dotfiles-dir.nix;

in
{
  # todo: make a wrapper for neovim to not include these system wide?
  #home.packages = with pkgs; [
  #  # for linting in neovim
  #  # todo: I think these are included in python-language-server
  #  python37Packages.autopep8
  #  python37Packages.flake8
  #  python37Packages.pycodestyle
  #  python37Packages.pydocstyle
  #  python37Packages.pyflakes
  #  python37Packages.pylint
  #  python37Packages.yapf        # formatting
  #  # python completion
  #  python37Packages.jedi
  #  python37Packages.python-language-server # palantir
  #];
  programs.neovim = {
    enable = true;
    withNodeJs = true; # enable node provider
    withPython3 = true;
    # these plugins can be found in `nixpkgs/pkgs/misc/vim-plugins`.
    plugins = with pkgs.vimPlugins; [
      #LanguageClient-neovim   # offload launage specific autocompletes and lints
      ack-vim # Run your favorite search tool from Vim, with an enhanced results list
      ale # linting of almost all languages
      ncm2 # awesome autocomplete plugin
      ncm2-bufword # completion from other buuffers
      ncm2-path # filepath completion
      ncm2-jedi # fast python completion (use ncm2 if you want type info or snippet support)
      nvim-yarp # dependency of ncm2
      indentLine # visual identation lines
      editorconfig-vim # respect editorconfig
      fzf-vim # fuzzy file finder
      ghcmod-vim
      gruvbox # color scheme
      haskell-vim
      rainbow # easier matching of parans
      surround # easy wrapping
      tmux-complete-vim # completion from tmux windows
      vim-airline # status bar
      vim-airline-themes # status bar themes
      jedi-vim # jedi for python
      vim-fugitive # vim operations
      vim-gitgutter # show changes in gutter
      vim-hdevtools
      vim-json
      vim-nix # nix configuration
      vim-ps1
      vim-puppet
      vim-signature # show marks in gutter
      #vim-stylish-haskell
      vim-terraform
      vim-test # invoke test runner
      vim-tmux-navigator # move between nvim and tmux
      vimproc-vim
    ];
    extraConfig = ''
      " # neovim setup
      " -------------------------------------------------------------
      " Map the leader key to space. Easy to reach with either hand and shouldn't
      " clobber other applications control sequences. Need to be mindful of tmux's
      " leader since neovim is very often run within a tmux session.
      let mapleader="\<SPACE>"

      " set the prefered color scheme.
      colorscheme gruvbox
      set background=dark

      " Allow backspace over everything in insert mode.
      set backspace=indent,eol,start
      " todo: what does removing `i` do?
      set complete-=i
      " try and guess where the next line should be indented.
      set smartindent
      " do notconsider octal (leading 0) as a number.
      set nrformats-=octal
      " greatly decraase the default (1000ms) timeout to wait for a mapped sequence to complete (<esc> sequences).
      set ttimeoutlen=100

      " # search settings
      " -------------------------------------------------------------

      " Highlight search results. Makes it easy to see all the matches.
      set hlsearch
      " Make searching case insensitive ...
      set ignorecase
      " ... unless the query has capital letters.
      set smartcase
      " jump to the first current match
      set incsearch
      " Use 'magic' patterns (extended regular expressions).
      set magic

      " Use <C-L> to clear the highlighting of :set hlsearch. Muscle memory maps
      " nicely to clearing a terminal.
      nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
      " }

      " # formattings
      " -------------------------------------------------------------
      set showcmd             " Show (partial) command in status line.
      set showmatch           " hlighlight matching brackets.
      set showmode            " Show current mode.
      set ruler               " Show the line and column numbers of the cursor.
      set number              " Show the line numbers on the left side.
      set formatoptions+=o    " Continue comment marker in new lines.
      set textwidth=0         " Hard-wrap long lines as you type them.
      set expandtab           " Insert spaces when TAB is pressed.
      set tabstop=2           " Render TABs using this many spaces.
      set shiftwidth=2        " Indentation amount for < and > commands.

      set noerrorbells        " No beeps. Noone like terminal bells.
      set modeline            " Enable modeline.
      set linespace=0         " Set line-spacing to minimum.
      set nojoinspaces        " Prevents inserting two spaces after punctuation on a join (J)

      " More natural splits
      set splitbelow          " Horizontal split below current.
      set splitright          " Vertical split to right of current.

      if !&scrolloff
        set scrolloff=3       " Show next 3 lines while scrolling.
      endif
      if !&sidescrolloff
        set sidescrolloff=5   " Show next 5 columns while side-scrolling.
      endif
      set display+=lastline
      set nostartofline       " Do not jump to first character with page commands.

      " Tell Vim which characters to show for expanded TABs,
      " trailing whitespace, and end-of-lines. VERY useful!
      if &listchars ==# 'eol:$'
        set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
      endif
      set list                " Show problematic characters.

      " Also highlight all tabs and trailing whitespace characters.
      highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
      match ExtraWhitespace /\s\+$\|\t/


      " # file configuration
      " -------------------------------------------------------------

      if has('path_extra')
        setglobal tags-=./tags tags^=./tags;
      endif

      set autoread            " If file updates, load automatically.
      set hidden

      " wrap commit message at 72 chracters, set a colorcolumn at 50 chracters for
      " the commit title.
      autocmd FileType gitcommit setlocal spell | setlocal tw=72 | setlocal colorcolumn=50

      " mail width at 72 chracters to preserve formatting when the message is quoted
      " in a reply by others
      autocmd FileType mail setlocal spell | setlocal tw=72

      " enable spell check when writing markdown
      autocmd FileType markdown setlocal spell

      " typicaly literate haskell is going to be embeded into a webage, so keep a
      " *hard* line length is critical to prevent users from having to scroll code
      " blocks.
      autocmd FileType lhaskell setlocal colorcolumn=72

      set updatetime=100 " quicker updates

      " Remove special characters for filename
      set isfname-=:
      set isfname-==
      set isfname-=+

      if &history < 1000
        set history=1000      " Number of lines in command history.
      endif
      if &tabpagemax < 50
        set tabpagemax=50     " Maximum tab pages.
      endif

      if &undolevels < 200
        set undolevels=200    " Number of undo levels.
      endif

      " Path/file expansion in colon-mode.
      set wildmenu
      set wildmode=list:longest
      set wildchar=<TAB>

      if !empty(&viminfo)
        set viminfo^=!        " Write a viminfo file with registers.
      endif
      set sessionoptions-=options

      " commands
      command! -nargs=0 -bar SiteDate execute "normal! A\<C-R>=strftime(\"%FT%TZ\")\<CR>"

      " Diff options
      set diffopt+=iwhite

      " use jk to exit insert mode. Escape key is a far reach.
      inoremap jk <Esc>`^
      "Enter to go to EOF and backspace to go to start
      nnoremap <CR> G
      nnoremap <BS> gg
      " Stop cursor from jumping over wrapped lines
      nnoremap j gj
      nnoremap k gk
      " Make HOME and END behave like shell
      inoremap <C-E> <End>
      inoremap <C-A> <Home>

      " # gui options
      " -------------------------------------------------------------

      " Relative numbering
      function! NumberToggle()
        if(&relativenumber == 1)
          set norelativenumber
          set number
        else
          set relativenumber
        endif
      endfunc

      " Toggle between normal and relative numbering.
      nnoremap <leader>r :call NumberToggle()<cr>

      " # keybindings
      " -------------------------------------------------------------

      " Save file
      nnoremap <Leader>w :w<CR>
      " load
      nnoremap <Leader>e :e<CR>
      "Copy and paste from system clipboard
      vmap <Leader>y "+y
      vmap <Leader>d "+d
      nmap <Leader>p "+p
      nmap <Leader>P "+P
      vmap <Leader>p "+p
      vmap <Leader>P "+P

      " Quickly edit/reload the vimrc file
      nmap <silent> <leader>ev :e $DOTFILES/home/neovim.nix<CR>

      nmap <silent> <leader>et :e $HOME/src/todo/todo.txt<CR>

      " # work with terminal
      " -------------------------------------------------------------
      "
      nnoremap <silent> <leader>tt :terminal<CR>            " new terminal
      nnoremap <silent> <leader>tv :vnew<CR>:terminal<CR>   " new terminal in vertical split
      nnoremap <silent> <leader>th :new<CR>:terminal<CR>    " new terminal in Horizontal split
      " Terminal settings
      tnoremap <Leader><ESC> <C-\><C-n>                     " escape terminal mode with leader esc
      tnoremap <Leader>jk <C-\><C-n>                        " or escape with jk, just like insert mode
      highlight TermCursor ctermfg=red guifg=red            " make the cursor red. Stands out more

      " file specific settings
      " -------------------------------------------------------------
      au FileType haskell nnoremap <buffer> <F1> :HdevtoolsType<CR>           " todo: remove this?
      au FileType haskell nnoremap <buffer> <silent> <F2> :HdevtoolsClear<CR> " todo: remove this?
      " }

      " # plugin settings
      " -------------------------------------------------------------

      " ## general
      " -------------------------------------------------------------

      " ## fugitive
      " -------------------------------------------------------------
      nnoremap <Leader>gc :Gcommit<CR>
      nnoremap <Leader>gs :Gstatus<CR>
      nnoremap <Leader>gd :Gdiff<CR>
      nnoremap <Leader>gb :Gblame<CR>
      nnoremap <Leader>gL :exe ':!cd ' . expand('%:p:h') . '; git la'<CR>
      nnoremap <Leader>gl :exe ':!cd ' . expand('%:p:h') . '; git las'<CR>
      nnoremap <Leader>gr :Gread<CR>
      nnoremap <Leader>gw :Gwrite<CR>
      nnoremap <Leader>gp :Git push<CR>
      nnoremap <Leader>g- :silent! Git stash<CR>:e<CR>
      nnoremap <Leader>g+ :silent! Git stash pop<CR>:e<CR>

      " ## airline
      " -------------------------------------------------------------
      let g:airline#extensions#tabline#enabled = 2
      let g:airline#extensions#tabline#fnamemod = ':t'
      let g:airline#extensions#tabline#left_sep = ' '
      let g:airline#extensions#tabline#left_alt_sep = '|'
      let g:airline#extensions#tabline#right_sep = ' '
      let g:airline#extensions#tabline#right_alt_sep = '|'
      let g:airline#extensions#ale#enabled = 1
      let g:airline_left_sep = ' '
      let g:airline_left_alt_sep = '|'
      let g:airline_right_sep = ' '
      let g:airline_right_alt_sep = '|'
      let g:airline_theme= 'gruvbox'

      " ## ale
      " -------------------------------------------------------------
      highlight ALEWarning ctermbg=DarkMagenta

      " ## fzf
      " -------------------------------------------------------------
      " linewise completion
      " <leader>o... for "open"
      imap <c-x><c-l> <plug>(fzf-complete-line)
      " Open file menu
      nnoremap <Leader>oo :Files<CR>
      " Open git tracked files (git ls-files)
      nnoremap <Leader>of :GFiles<CR>
      " Open buffer menu
      nnoremap <Leader>ob :Buffers<CR>
      " Open most recently used files
      nnoremap <Leader>oc :Commits<CR>

      " ## vim-tmux-navigation
      " -------------------------------------------------------------
      let g:tmux_navigator_no_mappings = 1
      nnoremap <silent> <A-h> :TmuxNavigateLeft<cr>
      nnoremap <silent> <A-j> :TmuxNavigateDown<cr>
      nnoremap <silent> <A-k> :TmuxNavigateUp<cr>
      nnoremap <silent> <A-l> :TmuxNavigateRight<cr>
      nnoremap <silent> <A-\> :TmuxNavigatePrevious<cr>

      " ## neo-ghc
      " -------------------------------------------------------------
      let g:haskellmode_completion_ghc = 1
      autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

      " ## vim-json
      " -------------------------------------------------------------
      let g:vim_json_syntax_conceal = 0

      " ## vim-test
      " -------------------------------------------------------------
      " these "Ctrl mappings" work well when Caps Lock is mapped to Ctrl
      nnoremap <Leader>tn :TestNearest<CR>
      nnoremap <Leader>tf :TestFile<CR>
      nnoremap <Leader>ts :TestSuite<CR>
      nnoremap <Leader>tl :TestLast<CR>
      nnoremap <Leader>tg :TestVisit<CR>

      " ## languageclient
      " -------------------------------------------------------------
      let g:LanguageClient_autoStart = 1

      nnoremap <F5> :call LanguageClient_contextMenu()<CR>

      " ## rainbow
      " -------------------------------------------------------------
      let g:rainbow_active = 1

      " ## ack
      " -------------------------------------------------------------
      if executable('ag')
        let g:ackprg = 'ag --vimgrep'
      endif

      " ## terraform
      " -------------------------------------------------------------
      let g:terraform_align=1
      let g:terraform_fold_sections=1
      let g:terraform_commentstring='//%s'
      let g:terraform_fmt_on_save=1

      " ## elm-vim setup
      " -------------------------------------------------------------
      " I like to set my own leader bindings
      let g:elm_setup_keybindings = 0

      "    " ## coc setup
      "    " -------------------------------------------------------------
      "    " Better display for messages
      "     set cmdheight=2

      "     " don't give |ins-completion-menu| messages.
      "     set shortmess+=c

      "     " always show signcolumns
      "     set signcolumn=yes

      "     " Use tab for trigger completion with characters ahead and navigate.
      "     " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
      "     inoremap <silent><expr> <TAB>
      "           \ pumvisible() ? "\<C-n>" :
      "           \ <SID>check_back_space() ? "\<TAB>" :
      "           \ coc#refresh()
      "     inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

      "     function! s:check_back_space() abort
      "       let col = col('.') - 1
      "       return !col || getline('.')[col - 1]  =~# '\s'
      "     endfunction

      "     " Use <c-space> to trigger completion.
      "     inoremap <silent><expr> <c-space> coc#refresh()

      "     " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
      "     " Coc only does snippet and additional edit on confirm.
      "     inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
      "     " Or use `complete_info` if your vim support it, like:
      "     " inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

      "     " Use `[g` and `]g` to navigate diagnostics
      "     nmap <silent> [g <Plug>(coc-diagnostic-prev)
      "     nmap <silent> ]g <Plug>(coc-diagnostic-next)

      "     " Remap keys for gotos
      "     nmap <silent> gd <Plug>(coc-definition)
      "     nmap <silent> gy <Plug>(coc-type-definition)
      "     nmap <silent> gi <Plug>(coc-implementation)
      "     nmap <silent> gr <Plug>(coc-references)

      "     " Use K to show documentation in preview window
      "     nnoremap <silent> K :call <SID>show_documentation()<CR>

      "     function! s:show_documentation()
      "       if (index(['vim','help'], &filetype) >= 0)
      "         execute 'h '.expand('<cword>')
      "       else
      "         call CocAction('doHover')
      "       endif
      "     endfunction

      "     " Highlight symbol under cursor on CursorHold
      "     autocmd CursorHold * silent call CocActionAsync('highlight')

      "     " Remap for rename current word
      "     nmap <leader>rn <Plug>(coc-rename)

      "     " Remap for format selected region
      "     xmap <leader>f  <Plug>(coc-format-selected)
      "     nmap <leader>f  <Plug>(coc-format-selected)

      "     augroup mygroup
      "       autocmd!
      "       " Setup formatexpr specified filetype(s).
      "       autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
      "       " Update signature help on jump placeholder
      "       autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
      "     augroup end

      "     " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
      "     xmap <leader>a  <Plug>(coc-codeaction-selected)
      "     nmap <leader>a  <Plug>(coc-codeaction-selected)

      "     " Remap for do codeAction of current line
      "     nmap <leader>ac  <Plug>(coc-codeaction)
      "     " Fix autofix problem of current line
      "     nmap <leader>qf  <Plug>(coc-fix-current)

      "     " Create mappings for function text object, requires document symbols feature of languageserver.
      "     xmap if <Plug>(coc-funcobj-i)
      "     xmap af <Plug>(coc-funcobj-a)
      "     omap if <Plug>(coc-funcobj-i)
      "     omap af <Plug>(coc-funcobj-a)

      "     " Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
      "     "nmap <silent> <C-d> <Plug>(coc-range-select)
      "     "xmap <silent> <C-d> <Plug>(coc-range-select)

      "     " Use `:Format` to format current buffer
      "     command! -nargs=0 Format :call CocAction('format')

      "     " Use `:Fold` to fold current buffer
      "     command! -nargs=? Fold :call     CocAction('fold', <f-args>)

      "     " use `:OR` for organize import of current buffer
      "     command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

      "     " Add status line support, for integration with other plugin, checkout `:h coc-status`
      "     " need to wrap in $ { ... }" to escape double single quotes.
      "     set statusline^=%{coc#status()}%{get(b:,'coc_current_function',${
    "''"
    })}

      "     " Using CocList
      "     " Show all diagnostics
      "     nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
      "     " Manage extensions
      "     nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
      "     " Show commands
      "     nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
      "     " Find symbol of current document
      "     nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
      "     " Search workspace symbols
      "     nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
      "     " Do default action for next item.
      "     nnoremap <silent> <space>j  :<C-u>CocNext<CR>
      "     " Do default action for previous item.
      "     nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
      "     " Resume latest coc list
      "     nnoremap <silent> <space>p  :<C-u>CocListResume<CR>


      " -------------------------------------------------------------
      " https://medium.com/@hanspinckaers/setting-up-vim-as-an-ide-for-python-773722142d1d
      " ncm2 settings
      autocmd BufEnter * call ncm2#enable_for_buffer()
      set completeopt=menuone,noselect,noinsert
      set shortmess+=c
      inoremap <c-c> <ESC>
      " make it fast
      let ncm2#popup_delay = 5
      " let ncm2#complete_length = [[1, 1]]
      " Use new fuzzy based matches
      let g:ncm2#matcher = 'substrfuzzy'
      " Disable Jedi-vim autocompletion and enable call-signatures options
      " let g:jedi#auto_initialization = 1
      " let g:jedi#completions_enabled = 0
      " let g:jedi#auto_vim_configuration = 0
      " let g:jedi#smart_auto_mappings = 0
      " let g:jedi#popup_on_dot = 0
      " let g:jedi#completions_command = ""
      let g:jedi#show_call_signatures = "1"

      " -------------------------------------------------------------
    '';
  };
}
