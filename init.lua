-- --------------------------------------------------
-- opt
-- --------------------------------------------------
vim.scriptencoding = 'utf-8'
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

vim.opt.signcolumn="yes"
vim.opt.lazyredraw=true               -- マクロなどを実行中は描画を中断
vim.opt.ttyfast=true
vim.opt.fileformat="unix"
vim.opt.virtualedit="block"             -- 短形選択は範囲外でも出来るようにする
vim.opt.sol=false                     -- 移動時にカーソルを極力同じ位置に
vim.opt.showmatch=true                -- 括弧の入力を強調
vim.opt.cmdheight=1                   -- ステータスラインは1行の表示のみとする
vim.opt.showcmd=true                  -- 入力中のコマンドを右下に表示
vim.opt.number=true                   -- 行番号表示
vim.opt.shiftwidth=4                  -- TAB文字の入力幅
vim.opt.tabstop=4                     -- TAB文字の表示幅
vim.opt.autoindent=true               -- 自動インデント
vim.opt.expandtab=true                -- タブをスペースに展開
vim.opt.softtabstop=4
-- smartindentは使わない。indentexpr(言語ごとのインデント計算)がある言語ではそもそも効かず、
-- 効くのは定義の無いファイルだけで、#で始まる行が行頭に飛ばされる等の癖があるため
vim.o.formatoptions="q"                 -- 自動改行OFF(vim.optへの文字列の代入だとlua_lsが以降のremove/appendを誤検知する)
vim.opt.formatoptions:remove("ro")    -- 改行時にコメントしない
vim.opt.formatoptions:append("mMjn")  -- 日本語向け。m:全角文字の間でも折り返す M:Jで全角の前後に空白を入れない j:Jでコメント記号を除く n:番号付きリストを整形
-- ftplugin(Lua/Vim/sh等はc,r,o,q,lを足す)が後から効くため、FileType(ftpluginの後に走る)で再適用する。
-- 上の起動時の設定だけだと、コメント行のEnter/oで記号が自動挿入される(r,o)状態に戻る。
-- 注意: 除去はテーブル形式(remove("ro")のような文字列形式は効かない)、追加は文字列形式(テーブル形式はエラー)。
-- 切り戻しはこのautocmdを削除
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("reapply_formatoptions", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
    vim.opt_local.formatoptions:append("mMjn")
  end,
})
vim.opt.display="lastline"              -- 長い一行でも表示されるように
vim.opt.matchtime=1                   -- 括弧入力時の飛ぶ時間を0.1の係数
vim.opt.textwidth=0                   -- 自動的に改行が入るのを無効化
vim.opt.spelllang:append("cjk")       -- スペルチェックから日本語を除外
vim.opt.backup=false                  -- バックアップ作成OFF
vim.opt.swapfile=false                -- スワップファイルをつくらない
vim.opt.autoread=true                 -- 他で書き換えられたら自動で読み込む
vim.opt.ruler=true                    -- カーソルが何行目の何列目に置かれているかを表示する
vim.opt.splitright=true               -- 新しいウィンドウを右に開く
vim.opt.splitbelow=true               -- 新しいウィンドウを下に開く
-- <C-o>/<C-i>で戻ったとき、画面のスクロール位置も元に戻す(view)。既定のclean(閉じたバッファを
-- ジャンプの履歴から除く)は残す。stack(戻ってから別の所へ飛ぶと先の履歴を消す)は動きが変わるので入れない
vim.opt.jumpoptions="clean,view"
vim.cmd('set matchpairs+=<:>')        -- 対応括弧に<と>のペアを追加
vim.opt.matchpairs:append({ "「:」", "（:）", "【:】", "［:］", "｛:｝", "＜:＞" }) -- 全角括弧も%や対応括弧ハイライトの対象にする
-- ファイル名補完で無視したいファイル
vim.cmd('set wildignore&')
vim.cmd('set wildignore+=*.bak,*.?~,*.??~,*.???~,*.~')
vim.cmd('set wildignore+=*.jar,*.war,*.class,*.obj,*.o')
-- 検索設定
vim.opt.incsearch=true                -- インクリメンタルサーチON
vim.opt.hlsearch=true                 -- 検索結果をすべてハイライト
vim.opt.ignorecase=true               -- 検索時に文字の大小を区別しない
vim.opt.smartcase=true                -- 検索時に大文字を含んでいたら大小を区別する
vim.opt.wrapscan=true                 -- 検索時にファイルの最後まで行ったら最初に戻る
vim.opt.wildmenu=false                -- コマンドライン補完するときに強化されたものを使う
vim.opt.wildmode="list:longest,full"
vim.cmd('set visualbell t_vb=')       -- 音設定（スクリーンベル音無効化）
vim.opt.visualbell=false
vim.opt.errorbells=false
-- クリップボード設定
vim.opt.clipboard:append({"unnamedplus"})
-- WSL(WSLg)でwl-clipboardを使う場合、Windowsでコピーした文字列のCRLFのCRが残り、
-- 貼り付けると行末に^Mが出るため、貼り付け時だけCRを取り除く。
-- cache_enabled=1でnvim内のコピー→貼り付けはwl-pasteを起動せず速い。Macでは何もしない
if vim.fn.has("wsl") == 1 and vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
  local wl_paste_lf = { "sh", "-c", "wl-paste --no-newline | tr -d '\\r'" }
  vim.g.clipboard = {
    name = "wsl-wl-clipboard (CR除去)",
    copy = {
      ["+"] = { "wl-copy", "--type", "text/plain" },
      ["*"] = { "wl-copy", "--type", "text/plain" },
    },
    paste = { ["+"] = wl_paste_lf, ["*"] = wl_paste_lf },
    cache_enabled = 1,
  }
end

vim.cmd('set nrformats=')             -- 数値認識の指定
vim.opt.scrolloff=5                   -- C-f,C-bのページ送り時に、この行数見えるようにする
vim.opt.sidescrolloff=10              -- 左右スクロール時の視界を確保
vim.opt.backspace="indent,eol,start"  -- バックスペースでインデントや改行を削除出来るようにする
vim.opt.showmatch=true                -- カーソル位置のカッコを強調表示
vim.opt.showtabline=2                 -- 常にタブラインを表示
vim.opt.fileencodings="utf-8,ucs-bom,iso-2022-jp,cp932,euc-jp,default,latin"
vim.opt.history=1024                  -- コマンド・検索パターンの履歴数
vim.opt.modeline=true
vim.opt.hidden=true                   -- 保存前でも裏バッファにいけるように
vim.opt.fileformats="unix,dos"        -- 新規ファイル作成時の改行コード指定
vim.opt.updatetime=500                -- CursorHold等の発火間隔（既定4000msから短縮。nvim-lint等での使用を想定）

-- 折りたたみ系
vim.opt.foldcolumn="auto:6"           -- 折りたたみの最深ネスト(上限6)に合わせて幅を自動調整。折りたたみが無ければ0列。元は"2"
vim.opt.fillchars:append("fold:─")    -- 折りたたみ行の埋め文字
vim.opt.foldlevel=15                  -- ネスト16段以上の折りたたみだけ最初から閉じる(実質全展開)。元は10
vim.opt.foldtext=""                   -- 閉じた折りたたみ行を先頭行そのまま(構文色付き)で表示。行数は出ない。元は既定のfoldtext()

-- treesitterによる折りたたみ(FileTypeごと・窓ローカル) ここから
-- パーサーが無いFileTypeは既定(manual)のまま
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_fold", { clear = true }),  -- :sourceでの再読込時に重複登録しない
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then return end
    if not vim.treesitter.get_parser(args.buf, lang, { error = false }) then return end  -- パーサーが無いFileTypeは除外
    vim.wo[0][0].foldmethod = "expr"
    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})
-- ここまで

-- --------------------------------------------------
-- filetype, syntax
-- --------------------------------------------------
-- :filetype plugin indent on はNeovimでは最初から有効なので書かない
-- (以前の vim.opt.filetype="plugin", "indent", "on" は'filetype'オプションに"plugin"を入れてしまっていた)
vim.opt.syntax="on"

-- --------------------------------------------------
-- leader key
-- --------------------------------------------------
vim.g.mapleader = " "

-- --------------------------------------------------
-- lazy.nvim
-- --------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- --------------------------------------------------
-- function
-- --------------------------------------------------
require('org_function')

-- 開いているバッファにlcd
vim.cmd([[
function! ChangeCurrentDirectory()
  let l:dir = expand("%:p:h")
  if isdirectory(fnamemodify(l:dir, ":p"))
    execute printf('lcd `=%s`', string(fnamemodify(l:dir, ":p")))
  endif
endfunction
]])


-- --------------------------------------------------
-- plugin setup
-- --------------------------------------------------
require("lazy").setup({
    "akinsho/toggleterm.nvim",        -- ターミナルトグル
    "nvim-lualine/lualine.nvim",      -- ステータスライン拡張
    "t9md/vim-quickhl",               -- 複数ハイライト,cmでハイライト。cjでカーソル行自動ハイライトモードに
    "lambdalisue/vim-mr",             -- 最近使ったファイル

-- 最近使ったファイル
    "thinca/vim-quickrun",            -- 簡易実行
    "Mofiqul/vscode.nvim",            -- colorscheme。vim-code-dark(2024-05で更新停止)から移行検証中
    { "folke/flash.nvim", event = "VeryLazy", opts = {} }, -- easymotion系
    {
      "WilliamHsieh/overlook.nvim",   -- 定義などを積み重ねられるフローティングで覗く(popupは実バッファ)。切り戻しはこのブロックを削除
      opts = {},
      keys = {
        -- sdpは既存のsd*(LSP系)に合わせる。popup内でもう一度押すと積み重なる。候補が複数ある定義はsdd(fzf)を使う
        { "sdp",        function() require("overlook.api").peek_definition() end, desc = "Overlook: peek definition" },
        { "<Leader>pp", function() require("overlook.api").peek_cursor() end,     desc = "Overlook: peek cursor" },
        { "<Leader>pu", function() require("overlook.api").restore_popup() end,   desc = "Overlook: restore popup" },
        { "<Leader>pc", function() require("overlook.api").close_all() end,       desc = "Overlook: close all" },
        { "<Leader>pf", function() require("overlook.api").switch_focus() end,    desc = "Overlook: switch focus" },
        { "<Leader>ps", function() require("overlook.api").open_in_split() end,   desc = "Overlook: open in split" },
        { "<Leader>pv", function() require("overlook.api").open_in_vsplit() end,  desc = "Overlook: open in vsplit" },
      },
    },
    {
      "Bekaboo/dropbar.nvim",          -- winbarにIDE風のパンくず(現在地のシンボル階層)を表示。LSPかtreesitterがあれば動く
      event = "VeryLazy",
      config = function()
        -- パンくずを出さないウィンドウ: diff中 / フロート(overlookの<Leader>pp、fzf-luaのプレビュー等) / ターミナル
        local function hidden(win)
          local buf = vim.api.nvim_win_get_buf(win)
          return vim.wo[win].diff or vim.fn.win_gettype(win) ~= "" or vim.bo[buf].buftype == "terminal"
        end
        local default_enable = require("dropbar.configs").opts.bar.enable
        require("dropbar").setup({
          bar = {
            enable = function(buf, win, info)
              return not hidden(win) and default_enable(buf, win, info)
            end,
          },
        })

        -- enableは新しく付けるかの判定だけなので、それだけでは消えない分を片付ける。
        -- ・フロートやsplitは開いた元のウィンドウのwinbarを引き継ぐ(元がパンくずならそのまま出てしまう)
        -- ・diffthisは既にパンくずが付いたウィンドウで始まる
        -- 逆にdiffoffしたウィンドウには付け直す
        local dropbar_winbar = "%{%v:lua.dropbar()%}"
        local function refresh()
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_is_valid(win) then
              if hidden(win) then
                if vim.wo[win].winbar == dropbar_winbar then
                  vim.wo[win].winbar = ""
                end
              elseif vim.wo[win].winbar == "" then
                require("dropbar.utils.bar").attach(vim.api.nvim_win_get_buf(win), win)
              end
            end
          end
        end
        vim.api.nvim_create_autocmd({ "WinNew", "BufWinEnter", "WinEnter", "TermOpen", "TabEnter" }, {
          group = vim.api.nvim_create_augroup("dropbar_hide", { clear = true }),
          callback = function() vim.schedule(refresh) end,
        })
        vim.api.nvim_create_autocmd("OptionSet", {
          group = "dropbar_hide",
          pattern = "diff",
          callback = function() vim.schedule(refresh) end,
        })
      end,
      keys = {
        -- sdbは既存のsd*(LSP系)に合わせる。sds(fzf lsp_document_symbols)とは別物で、
        -- こちらはwinbar上でその場のシンボル階層を直接選ぶ
        { "sdb", function() require("dropbar.api").pick() end,                desc = "Dropbar: pick symbol in winbar" },
        { "[;",  function() require("dropbar.api").goto_context_start() end,  desc = "Dropbar: go to context start" },
        { "];",  function() require("dropbar.api").select_next_context() end, desc = "Dropbar: select next context" },
      },
    },
    "kylechui/nvim-surround",         -- surround系
    {
      -- 開いたファイルの中身から、インデントがタブかスペースか・幅(2/4等)を判別して設定する。
      -- .editorconfigがあればそちらを優先する。新規/空のファイルはFileTypeごとの既定(filetype, syntaxを参照)のまま
      "NMAC427/guess-indent.nvim",
      opts = {},
    },
    {
      -- HTML/JSX等でタグを自動で閉じる(<div>と打つと</div>も入る)。開始タグ名を変えると閉じタグも変わる
      "windwp/nvim-ts-autotag",
      event = { "BufReadPre", "BufNewFile" },
      opts = {},
    },
    {
      -- 関数・クラス・引数を単位にした選択(vaf, dia, cif等)。nvim-treesitterがmainブランチなのでこちらもmain。
      -- 設定はPlugin:nvim-treesitter-textobjectsを参照
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
    },
    {
      -- TODO:/FIXME:/HACK:/NOTE:等のコメントを色付けする
      "folke/todo-comments.nvim",
      event = { "BufReadPost", "BufNewFile" },
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {},
    },
    {
      -- 括弧・引用符の自動補完。(で)も入る、閉じ括弧の手前で)を打つと飛び越える、
      -- 空の()でBackspaceすると両方消える、{}の間でEnterすると3行に分けてインデントする
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      opts = {
        check_ts = true, -- treesitterで判定し、言語ごとに決められた文字列の中(Luaの文字列等)では補完しない(コメントの中は補完する)
        -- <C-h>もBackspaceとして使うので、空の()で<C-h>を押したときも両方消す(既定はBackspaceだけ)
        map_c_h = true,
        -- 空の()の間で<C-w>を押したときも、)を残さず対を消す。それ以外の場所では普通の<C-w>(単語の削除)
        map_c_w = true,
      },
    },
    "monaqa/dial.nvim",               -- true/false等の切り替え。dps-dial.vim(+denops)から移行
    "folke/which-key.nvim",           -- key bind help
    "lewis6991/gitsigns.nvim",        -- git
    "NeogitOrg/neogit",               -- git
    "sindrets/diffview.nvim",         -- git
    "MattesGroeger/vim-bookmarks",    -- mark update
    "shellRaining/hlchunk.nvim",      -- hlchunk
    {
      -- 右端にスクロールバーを出し、今見ている範囲と、診断・gitの変更の位置を示す
      "petertriho/nvim-scrollbar",
      dependencies = {
        "lewis6991/gitsigns.nvim",
        "kevinhwang91/nvim-hlslens", -- 検索の一致の横に「[2/10]」(何件目/全件数)を出す
      },
      config = function()
        -- 検索中(ハイライトが出ていて一致がある間)は、検索とカーソルの印だけを出し、診断・gitの印は隠す。
        -- <C-l>(:nohlsearch)等で検索のハイライトを消すと、元どおり全部出る。
        -- 描画(render)のときだけ読み出す印を絞るので、保存されている印自体は消さない。
        -- setupの中で描画関数を取り込む(throttle)ため、setupより前に差し替える
        local scrollbar, sb_utils = require("scrollbar"), require("scrollbar.utils")
        local render = scrollbar.render
        ---@diagnostic disable-next-line: duplicate-set-field
        scrollbar.render = function()
          local get = sb_utils.get_scrollbar_marks
          ---@diagnostic disable-next-line: duplicate-set-field
          sb_utils.get_scrollbar_marks = function(bufnr)
            local marks = get(bufnr)
            if vim.v.hlsearch == 1 and marks.search and #marks.search > 0 then
              return { search = marks.search, cursor = marks.cursor }
            end
            return marks
          end
          local ok, err = pcall(render)
          sb_utils.get_scrollbar_marks = get
          if not ok then error(err) end
        end

        require("scrollbar").setup({
          -- これより行数が多いバッファでは出さない(スクロールのたびに印を計算し直すため、巨大なファイルで重くしない)
          max_lines = 10000,
          -- 今見ている範囲(つまみ)。既定のCursorColumn(#222222)は背景とほぼ同じ色で見えないため、
          -- VSCodeのスクロールバーのつまみに近い灰色をそのまま(半透明にせず)出す
          handle = { color = "#424242", blend = 0 },
          marks = {
            -- カーソルの位置。既定の小さな白い点(•)は本文と同じ色で埋もれるため、黄色の太い横線にする。
            -- priorityは既定の0(数字が小さいほど優先)のままで、他の印と重なってもカーソルが出る
            Cursor = { text = "━", color = "#ffcc00" },
            -- 検索の一致。既定はSearchの文字色を使うが、vscodeの配色のSearchは背景色だけで文字色が無く、
            -- 黒(#000000)になって見えないため、色を明示する(カーソルの黄色と区別できるオレンジ)
            Search = { color = "#ff8c00" },
          },
        })
        require("scrollbar.handlers.gitsigns").setup() -- gitの追加/変更/削除の位置も出す
        -- 検索の一致の位置も出す。scrollbar側はhlslensの設定(build_position_cb)を書き換えるだけで
        -- hlslens自体は起動しないので、先にhlslensをsetupしてから連携させる
        require("hlslens").setup()
        require("scrollbar.handlers.search").setup()
        -- 行末の表示([31/33]、[7N 24]等)。既定は一番近い一致の表示が一致そのもの(CurSearch)と同じ黄色の背景で、
        -- 一致した文字と見分けにくいため、どちらも目立たない薄い灰色の背景にそろえ、一番近いものだけ黄色の太字にする。
        -- hlslensは既定値(default)で色を付けるので、明示すれば優先される。colorschemeの読み直しでも付け直す
        local function lens_hl()
          vim.api.nvim_set_hl(0, "HlSearchLens", { fg = "#bbbbbb", bg = "#3a3d41" })
          vim.api.nvim_set_hl(0, "HlSearchLensNear", { fg = "#fce094", bg = "#3a3d41", bold = true })
        end
        lens_hl()
        vim.api.nvim_create_autocmd("ColorScheme", {
          group = vim.api.nvim_create_augroup("hlslens_near_hl", { clear = true }),
          callback = lens_hl,
        })

        -- 検索の移動のたびにhlslensの表示([2/10])を出し直す(hlslensの推奨の割り当て)
        local function lens(keys)
          return keys .. "<Cmd>lua require('hlslens').start()<CR>"
        end
        local opts = { noremap = true, silent = true }
        -- n/N: :normal!の中で検索すると、Neovimが普段出す「/検索語」と「[3/4]」がメッセージ欄に出ないため、
        -- 移動後に同じ形(左に検索語、右端に件数)で自分で出す。末尾/先頭で折り返したときはそれも出す
        local function search_jump(key)
          return function()
            local before = vim.api.nvim_win_get_cursor(0)
            local ok, err = pcall(vim.cmd --[[@as function]], "normal! " .. vim.v.count1 .. key)
            if not ok then
              vim.api.nvim_echo({ { (tostring(err):gsub("^.-(E%d+:)", "%1")), "ErrorMsg" } }, false, {})
              return
            end
            require("hlslens").start()

            local after = vim.api.nvim_win_get_cursor(0)
            -- 下向き(/でのn、?でのN)に進んだのに前に戻った/上向きなのに後ろに進んだ = 折り返した
            local down = (vim.v.searchforward == 1) == (key == "n")
            local moved_back = after[1] < before[1] or (after[1] == before[1] and after[2] < before[2])
            local wrapped = down == moved_back and not vim.deep_equal(before, after)

            local sc_ok, sc = pcall(vim.fn.searchcount, { maxcount = 9999, timeout = 200 })
            local count = (sc_ok and sc.total and sc.total > 0) and ("[%d/%d]"):format(sc.current, sc.total) or ""
            local left = (vim.v.searchforward == 1 and "/" or "?") .. vim.fn.getreg("/")
            local note = wrapped and (down and "  (末尾から先頭へ)" or "  (先頭から末尾へ)") or ""
            -- 1行に収める(右端のruler/showcmdの分は除く)。長い検索語は…で切る
            local width = vim.v.echospace - 1
            local room = width - vim.fn.strdisplaywidth(note) - vim.fn.strdisplaywidth(count) - 1
            if vim.fn.strdisplaywidth(left) > room then
              left = vim.fn.strcharpart(left, 0, math.max(room - 1, 1)) .. "…"
            end
            local pad = math.max(width - vim.fn.strdisplaywidth(left .. note .. count), 1)
            vim.api.nvim_echo({ { left }, { note, "WarningMsg" }, { string.rep(" ", pad) .. count } }, false, {})
          end
        end
        vim.keymap.set("n", "n", search_jump("n"), opts)
        vim.keymap.set("n", "N", search_jump("N"), opts)
        vim.keymap.set("n", "*", lens("*"), opts)
        vim.keymap.set("n", "#", lens("#"), opts)
        vim.keymap.set("n", "g*", lens("g*"), opts)
        vim.keymap.set("n", "g#", lens("g#"), opts)
      end,
    },
    {
      "L3MON4D3/LuaSnip",             -- スニペット
      -- friendly-snippetsの変換(${1/(.*)/${1:/upcase}/}等)を使うスニペットに必要なjsregexpをビルドする
      build = "make install_jsregexp",
    },
    {
      "saghen/blink.cmp",              -- 補完系
      version = "1.*",
      dependencies = {
        "rafamadriz/friendly-snippets",
        "xzbdmw/colorful-menu.nvim",   -- 補完候補のラベルをtreesitterの色で表示する
      },
      -- build = "cargo build --release", -- プリビルドバイナリの自動取得に失敗する環境でのみ有効化
    },
    "stevearc/quicker.nvim",          -- quickfix拡張
    -- LSP setting
    {
      "mason-org/mason-lspconfig.nvim",
      dependencies = {
        {
          "mason-org/mason.nvim",
          opts = {}, -- setup()が必要なためoptsを指定
        },
        "neovim/nvim-lspconfig",
      },
      opts = {
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
        ensure_installed = {
          "lua_ls",
          "vimls",
          "sqlls",
          "html",
          "bashls",
          "jdtls",
          "jsonls",
          "cssls",
          "yamlls",
          "basedpyright", -- Python。型チェック・補完・定義ジャンプ等。pylspから移行
          "ruff", -- basedpyrightと併用。高速なリント/フォーマットを担当
          "ts_ls",  -- JavaScript/TypeScript
          "eslint", -- eslintの診断とコードアクション(自動修正)。nvim-lint+eslint_dから移行
          "cssmodules_ls",
          "marksman", -- Markdown用。リンク・見出しの補完/ジャンプ/リンク切れの診断
        },
        -- jdtlsはnvim-jdtlsが起動するので、mason-lspconfigによる自動のvim.lsp.enableから外す
        -- (インストールだけはensure_installedで行う)
        automatic_enable = { exclude = { "jdtls" } },
      },
      config = function(_, opts)
        require("mason-lspconfig").setup(opts)
      end,
    },

    {
      "WhoIsSethDaniel/mason-tool-installer.nvim", -- mason経由でLSP以外のツール(リンター等)も自動インストール
      dependencies = { "mason-org/mason.nvim" },
      opts = {
        ensure_installed = {
          "shellcheck", -- sh
          "stylelint",  -- css
          "sqlfluff",   -- sql
          "prettier",   -- js/ts/css/html/json/yaml/markdownのフォーマッタ(conform.nvim)
          "shfmt",      -- shのフォーマッタ(conform.nvim)
        },
      },
    },

    {
      -- ファイルタイプごとにフォーマッタを選ぶ。定義がなければLSPのフォーマットを使う。
      -- 設定はPlugin:conformを参照
      "stevearc/conform.nvim",
      cmd = { "ConformInfo" },
    },

    {
      -- init.luaやプラグインを書くときに、lua_lsへvim.*のAPIやプラグインの型定義を渡す
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          -- vim.uv(libuv)の型定義。`vim.uv`と書いたときだけ読み込む
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },

    {
      -- LSPの起動・インデックス作成などの進捗を右下に表示する
      "j-hui/fidget.nvim",
      event = "LspAttach",
      opts = {},
    },

    {
      -- jdtls(Java)の起動と拡張機能(import整理、変数/メソッド抽出、テスト実行等)。
      -- 起動はPlugin:javaのFileType autocmdで行う
      "mfussenegger/nvim-jdtls",
      ft = "java",
    },

    {
      "mfussenegger/nvim-lint", -- LSP以外の外部リンターをvim.diagnosticに統合
      config = function()
        local lint = require("lint")
        -- js/tsのeslintはLSP(eslint)で行う
        lint.linters_by_ft = {
          sh = { "shellcheck" },
          css = { "stylelint" },
          sql = { "sqlfluff" },
        }

        -- 入力停止時（挿入モード離脱時／挿入中・通常モードで入力が止まった時の両方）に加え、
        -- filetype変更時（,ft等での:set ft=）にも再チェックする
        vim.api.nvim_create_autocmd({ "InsertLeave", "CursorHoldI", "CursorHold", "FileType" }, {
          callback = function()
            lint.try_lint()
          end,
        })
      end,
    },

    {
      'MagicDuck/grug-far.nvim',
      config = function()
        require('grug-far').setup({});
      end
    },

    "kevinhwang91/nvim-bqf",

    "stevearc/oil.nvim",
    "thinca/vim-qfreplace",
    {
      "ibhagwan/fzf-lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        branch = 'main',
        lazy = false,
        build = ":TSUpdate",
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
          "MunifTanjim/nui.nvim",
        },
    },
    -- markdown装飾プラグイン。markview.nvimと比較検証中のため、
    -- render-markdown.nvim側を一時的にコメントアウトしている。
    -- 戻す場合は下のmarkview.nvimのブロックと入れ替える
    -- {
    --   -- markdownをバッファ内でその場で装飾する。md-render.nvimから移行。
    --   -- md-renderはプレビューを開くたびに全文を同期描画するため行数に比例して
    --   -- 重くなっていた(561行で約115ms、4488行で約590ms)。こちらは表示中の
    --   -- 画面内だけをextmarkで描画するのでファイルサイズの影響を受けない
    --   "MeanderingProgrammer/render-markdown.nvim",
    --   dependencies = {
    --     "nvim-treesitter/nvim-treesitter",
    --     "nvim-tree/nvim-web-devicons",
    --   },
    --   ft = { "markdown" },
    --   ---@module 'render-markdown'
    --   ---@type render.md.UserConfig
    --   opts = {
    --     -- 既定(enabled=true)のまま。markdownを開いた時点で装飾された状態になり、
    --     -- <leader>mpは「生のmarkdownに戻す」トグルとして働く
    --     anti_conceal = { enabled = true }, -- カーソル行だけ生のmarkdownを見せる
    --     latex = { enabled = false },       -- latexパーサーも変換コマンドも未導入のため切る
    --     sign = { enabled = false },        -- gitsignsとsign columnを奪い合うため切る
    --     completions = { lsp = { enabled = true } }, -- blink.cmpへチェックボックス/コールアウト補完を出す
    --   },
    --   keys = {
    --     { "<leader>mp", "<cmd>RenderMarkdown buf_toggle<cr>", desc = "Markdown render (toggle)" },
    --     { "<leader>mt", "<cmd>RenderMarkdown preview<cr>",    desc = "Markdown render preview (side)" },
    --   },
    -- },
    {
      "OXY2DEV/markview.nvim",
      -- 本体が既に遅延読み込み済みで、lazy.nvim側での遅延は公式に非推奨
      -- (プレビュー表示がかえって遅くなる)
      lazy = false,
      dependencies = { "saghen/blink.cmp" }, -- チェックボックス等の補完連携
      opts = {
        preview = {
          -- render-markdown.nvimのanti_conceal相当。カーソル下のノードだけ
          -- 装飾を外して生のmarkdownを見せる(既定は{}=無効)
          hybrid_modes = { "n" },
        },
      },
      keys = {
        { "<leader>mp", "<cmd>Markview toggle<cr>",      desc = "Markdown render (toggle)" },
        { "<leader>mt", "<cmd>Markview splitToggle<cr>", desc = "Markdown preview (split)" },
      },
    },
    {
      -- 自作の右下フロート型チートシート。GitHub公開(public)につきdirではなくurlで読み込む。
      -- 手元で編集する場合は ~/neovim_plugin/floatsheet.nvim を直接いじってpushし、
      -- :Lazy syncで反映する(dir指定のようにローカル変更が即時反映されるわけではない)
      "doragura876/floatsheet.nvim",
      lazy = false, -- 下のPlugin:floatsheetで直後にsetupするため
    },
})

-- --------------------------------------------------
-- colorscheme
-- --------------------------------------------------
vim.cmd('set termguicolors')
vim.cmd('set t_Co=256')
vim.cmd('set t_ut=')

-- transparent=true: パレットの背景色(vscBack)をNONEにして、Neovimが背景を塗らないようにする
-- (実際に透けるかはターミナル側の設定次第)。フロート/ポップアップの背景は残る。
-- backgroundはターミナルの背景色問い合わせでlightと判定されるとライト配色になるため固定する
vim.o.background = 'dark'
require('vscode').setup({
  transparent = true,
  group_overrides = {
    -- 選択中のタブ。移行前のcodedark(手書きの変更)と同じオリーブ色。
    -- nvim_set_hlは丸ごと置き換えるので、fgも必ず一緒に指定する
    TabLineSel = { fg = '#D4D4D4', bg = '#4B5632' },
    -- winbar(dropbarのパンくず)。transparentで背景が無く本文と同じ色だと、コードの1行目に見えてしまうため、
    -- タブラインと同系統の背景色で帯にし、文字は本文より抑えめにする。非アクティブの窓はさらに暗くする
    WinBar = { fg = '#BBBBBB', bg = '#2D2D2D' },
    WinBarNC = { fg = '#858585', bg = '#252526' },
  },
})
vim.cmd('colorscheme vscode')

-- タブラインの空き領域。素のvscodeだと#252526で塗られるので透過にする
vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })

-- --------------------------------------------------
-- temp
-- --------------------------------------------------


-- --------------------------------------------------
-- nvim-bqf
-- --------------------------------------------------
---@diagnostic disable-next-line: missing-fields
require("bqf").setup({
    -- https://github.com/kevinhwang91/nvim-bqf#customize-configuration
    func_map = {
        -- 空文字列を指定することでデフォルトのショートカットを無効化
        pscrolldown = '<C-S-f>', -- デフォルト: <C-f> (半ページ下へスクロール)
        pscrollup   = '<C-S-b>', -- デフォルト: <C-b> (半ページ上へスクロール)
        prevfile = '',
        nextfile = '',
    }
})

-- --------------------------------------------------
-- grep結果に色をつける
-- --------------------------------------------------
-- 2. grep用のハイライト設定
vim.api.nvim_create_autocmd("FileType", {
  pattern = "grep",
  callback = function()
    vim.cmd("syntax on")
    -- 既存の構文設定をリセット
    vim.cmd("syntax clear")

    -- 1. ファイル名: 行頭から「最初のコロン」まで。コロン自体は含めない(me=e-1)
    vim.cmd([[syntax match grepFileName /^[^:]\+:/me=e-1]])

    -- 2. 行番号: 「最初のコロン」と「二番目のコロン」の間にある数字。
    -- \zs と \ze を使って、マッチの開始と終了を数字部分だけに限定します
    vim.cmd([[syntax match grepLineNumber /:\zs\d\+\ze:/]])

    -- 3. 色の割り当て (お好みに合わせて変更可能です)
    -- ファイル名: Directory (通常は青)
    vim.api.nvim_set_hl(0, 'grepFileName', { fg = '#935383' })
    -- 行番号: Special (通常はオレンジ/黄色系)
    vim.api.nvim_set_hl(0, 'grepLineNumber', { fg = '#818e55' })

    -- コロンだけ色を変えたい場合は、上記 match の後にさらに細かく定義も可能ですが、
    -- まずはこの2色分けが最も視認性が高いです。
  end,
})

-- 標準入力で起動した際に、中身がgrepっぽければ自動でfiletypeを設定
vim.api.nvim_create_autocmd("StdinReadPost", {
  callback = function()
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
    -- 最初の行が "ファイル名:行番号:" の形式にマッチするか簡易チェック
    if first_line:match("^[^:]+:%d+:") then
      vim.bo.filetype = "grep"
    end
  end,
})

-- --------------------------------------------------
-- quicker
-- --------------------------------------------------
require("quicker").setup({
   opts = {
    cursorline = true, -- カーソル行のハイライトを有効にする
  },
  keys = {
    { ">", "<cmd>lua require('quicker').expand()<CR>", desc = "Expand quickfix content" },
    { "<", "<cmd>lua require('quicker').collapse()<CR>", desc = "Collapse quickfix content" },
  },
  -- Maximum width of the filename column
  max_filename_width = function()
    return math.floor(math.min(65, vim.o.columns / 2))
  end,
  vim.api.nvim_set_hl(0, "CursorLine", { underline = true }),
})

-- location list git grep ver
local function grep_to_loc(opts)
  local input = opts.args
  if not input or input == "" then
    print("引数を指定してください")
    return
  end

  local stdout_data = {}
  local cmd = string.format('git grep -n %s', input)

  -- 1. コマンドを実行した現在のウィンドウIDを保存しておく
  local win_id = vim.api.nvim_get_current_win()

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      stdout_data = data
    end,
    on_exit = function()
      vim.schedule(function()
        local lines = {}
        for _, line in ipairs(stdout_data) do
          if line ~= "" then table.insert(lines, line) end
        end

        if #lines > 0 then
          -- 2. setloclist を使用し、第1引数に保存したウィンドウIDを指定する
          vim.fn.setloclist(win_id, {}, 'r', {
            title = 'Grep (Loc): ' .. input,
            lines = lines,
          })

          -- 3. 保存したウィンドウのコンテキストで lwindow を実行してリストを開く
          vim.api.nvim_win_call(win_id, function()
            vim.cmd('lwindow')
          end)
          -- LocationリストのウィンドウIDを取得してフォーカスを移動
          local loc_info = vim.fn.getloclist(win_id, { winid = 0 })
          if loc_info.winid > 0 then
            vim.api.nvim_set_current_win(loc_info.winid)
          end
        else
          print("No matches found or error for: " .. input)
        end
      end)
    end,
  })
end

vim.api.nvim_create_user_command('GG', grep_to_loc, { nargs = '+' })

-- location list grep ver
local function grep_to_loclist(opts)
  -- 1. Exコマンドの引数を受け取る (opts.args に入力文字列全体が入る)
  local input = opts.args
  if not input or input == "" then
    print("引数を指定してください")
    return
  end

  local stdout_data = {}
  local cmd = string.format('grep -rn %s .', input)

  -- コマンドを実行した現在のウィンドウIDを保存しておく
  local win_id = vim.api.nvim_get_current_win()

  -- 3. 非同期ジョブの開始
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      stdout_data = data
    end,
    on_exit = function()
      -- メインスレッドで処理
      vim.schedule(function()
        local lines = {}
        for _, line in ipairs(stdout_data) do
          if line ~= "" then table.insert(lines, line) end
        end

        if #lines > 0 then
          vim.fn.setloclist(win_id, {}, 'r', {
            title = 'Grep: ' .. input,
            lines = lines,
          })

          -- 3. 保存したウィンドウのコンテキストで lwindow を実行してリストを開く
          vim.api.nvim_win_call(win_id, function()
            vim.cmd('lwindow')
          end)
          -- LocationリストのウィンドウIDを取得してフォーカスを移動
          local loc_info = vim.fn.getloclist(win_id, { winid = 0 })
          if loc_info.winid > 0 then
            vim.api.nvim_set_current_win(loc_info.winid)
          end
        else
          print("No matches found or error for: " .. input)
        end
      end)
    end,
  })
end
vim.api.nvim_create_user_command('Gg', grep_to_loclist, { nargs = '+' })

vim.api.nvim_create_user_command('QFToBuf', function()
  local qflist = vim.fn.getqflist()
  local lines = {}

  for _, item in ipairs(qflist) do
    if item.valid == 1 then
      local filename = vim.fn.bufname(item.bufnr)
      local line = string.format("%s:%d:%d:%s", filename, item.lnum, item.col, item.text)
      table.insert(lines, line)
    end
  end

  if #lines == 0 then
    vim.notify("Quickfixリストが空か、有効なアイテムがありません。", vim.log.levels.WARN)
    return
  end

  -- ★ここを変更: 新規タブを作成してそのバッファに移動する
  vim.cmd('tabnew')

  -- 新しいバッファにテキストを書き込む
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

  -- 一時バッファとして設定
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false
end, { desc = "Export Quickfix to a new tab in grep format" })

vim.api.nvim_create_user_command('LocToBuf', function()
  -- 現在のウィンドウ(0)のロケーションリストを取得
  local loclist = vim.fn.getloclist(0)
  local lines = {}

  for _, item in ipairs(loclist) do
    if item.valid == 1 then
      local filename = vim.fn.bufname(item.bufnr)
      -- grep形式 (ファイル名:行番号:列番号:テキスト)
      local line = string.format("%s:%d:%d:%s", filename, item.lnum, item.col, item.text)
      table.insert(lines, line)
    end
  end

  if #lines == 0 then
    vim.notify("現在のウィンドウにロケーションリストがないか、有効なアイテムがありません。", vim.log.levels.WARN)
    return
  end

  -- 新規タブを作成
  vim.cmd('tabnew')

  -- 新しいバッファにテキストを書き込む
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

  -- 一時バッファとして設定
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false
end, { desc = "Export Location List to a new tab in grep format" })


-- --------------------------------------------------
-- oil
-- --------------------------------------------------
require("oil").setup{
 default_file_explorer = false,
 vim.keymap.set('n', '<leader>o', ":Oil --float<CR>", { noremap = true, silent = true, desc = "oil filer" }),
}

-- --------------------------------------------------
-- Plugin:which-key
-- --------------------------------------------------
require('which-key').setup{
 triggers = {
   { "<leader>", mode = { "n", "v" } },
   { "s", mode = { "n", "v" } },
   { ",,", mode = { "n", "v" } },
   { "z", mode = { "n", "v" } },
   { "m", mode = { "n", "v" } },
 },
}

-- --------------------------------------------------
-- Plugin:floatsheet
--   https://github.com/doragura876/floatsheet.nvim (開発は~/neovim_plugin/floatsheet.nvim)。
--   覚えたいキーをmarkdownで書いて右下に出しっぱなしにする。
--   ページはfloatsheet.mdの「# 1:名前」見出し。先頭の「英数:」が<Leader>?<その文字>の移動キーになる
-- --------------------------------------------------
require('floatsheet').setup{
  jump_prefix = "<Leader>?",
}
require('which-key').add({ { "<Leader>?", group = "floatsheet" } })
vim.keymap.set("n", "<Leader>??", function() require('floatsheet').toggle() end, { noremap = true, silent = true, desc = "floatsheet toggle" })
vim.keymap.set("n", "<Leader>?n", function() require('floatsheet').next() end, { noremap = true, silent = true, desc = "floatsheet next page" })
vim.keymap.set("n", "<Leader>?p", function() require('floatsheet').prev() end, { noremap = true, silent = true, desc = "floatsheet prev page" })
vim.keymap.set("n", "<Leader>?e", function() require('floatsheet').edit() end, { noremap = true, silent = true, desc = "floatsheet edit page" })

-- --------------------------------------------------
-- Plugin:Neogit
-- --------------------------------------------------
require('neogit').setup{
 vim.keymap.set('n', '<leader>gg', ":Neogit cwd=%:p:h<CR>", { noremap = true, silent = true, desc = "neogit" }),
}

-- NeogitLogView: <S-CR>/<C-CR>でddと同じ動作(DiffPopup -> this = カーソル行の
-- コミットをdiffviewで開く)をさせる。Neogit本体のロジックをそのまま使うため、
-- API直呼びではなく"dd"というキー入力自体を流し込む
local function neogit_diff_this()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("dd", true, false, true), "m", false)
end

-- Neogitの Buffer.create は「filetype設定 → (この時点でFileTypeが発火) →
-- 本体のデフォルトキーマップ設定」という順序のため、ここで即座にmapすると
-- 直後に本体側の<S-CR>=PeekFileで上書きされてしまう。vim.scheduleで
-- 本体の初期化が終わったあとに上書きする
vim.api.nvim_create_autocmd("FileType", {
  pattern = "NeogitLogView",
  callback = function(args)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then
        return
      end
      vim.keymap.set("n", "<S-CR>", neogit_diff_this,
        { noremap = true, silent = true, buffer = args.buf, desc = "Diff this (same as dd)" })
      vim.keymap.set("n", "<C-CR>", neogit_diff_this,
        { noremap = true, silent = true, buffer = args.buf, desc = "Diff this (same as dd)" })
    end)
  end,
})

-- --------------------------------------------------
-- Plugin:Diffview
-- --------------------------------------------------
-- neogitからのdiff（DiffPopup）も含め、ファイルパネル（変更ファイル一覧）を
-- 左ではなく画面上部に表示する。左右ファイルのdiff自体は従来通り左右表示のまま。
-- diff_buf_readで追加したバッファローカルキーマップを記録しておき、
-- view_closedで確実に取り除く（作業ツリー側の差分は実ファイルのバッファを
-- そのまま使い回すため、外し忘れるとDiffviewを閉じた後も普段の編集画面に
-- キーマップが残ってしまう）
local diffview_diff_buf_keys = {}

local function diffview_cleanup_diff_buf_keys()
  for bufnr, keys in pairs(diffview_diff_buf_keys) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      for _, lhs in ipairs(keys) do
        pcall(vim.keymap.del, "n", lhs, { buffer = bufnr })
      end
    end
  end
  diffview_diff_buf_keys = {}
end

require('diffview').setup{
  -- 左(変更前)の窓で削除行をDiffAdd(緑)ではなくDiffDelete(赤)で表示し、
  -- 反対側の追加に対応する埋め合わせ行(filler)を目立たない色にする
  enhanced_diff_hl = true,
  file_panel = {
    win_config = {
      position = "top",
      height = 10,
    },
  },
  hooks = {
    -- 左右のdiffバッファ（実ファイルのfiletypeを持つため下のautocmdでは拾えない）にもqを割り当てる
    diff_buf_read = function(bufnr)
      vim.keymap.set("n", "q", ":<C-u>DiffviewClose<CR>",
        { noremap = true, silent = true, buffer = bufnr, desc = "DiffviewClose" })
      vim.keymap.set("n", "<leader><leader>", require("diffview_extra").toggle_file_panel_position,
        { noremap = true, silent = true, buffer = bufnr, desc = "Toggle file panel position" })
      diffview_diff_buf_keys[bufnr] = { "q", "<leader><leader>" }
    end,
    view_closed = diffview_cleanup_diff_buf_keys,
  },
}

-- ファイルパネル(file_panel)の位置を top <-> left でトグルする。
-- Panel:open()はopenのたびにfile_panel.win_config.positionを読み直すため、
-- ここで値を書き換えてからパネルをclose→openし直せば反映される。
package.preload["diffview_extra"] = function()
  local M = {}

  function M.toggle_file_panel_position()
    local view = require("diffview.lib").get_current_view() --[[@as StandardView?]]
    if not view or not view.panel then
      return
    end

    local win_config = require("diffview.config").get_config().file_panel.win_config
    win_config.position = (win_config.position == "top") and "left" or "top"

    view.panel:close()
    view.panel:open()
  end

  return M
end

-- Diffviewのファイルパネル/ファイル履歴パネルでqを押したらDiffviewを閉じる
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "DiffviewFiles", "DiffviewFileHistory" },
  callback = function(args)
    vim.keymap.set("n", "q", ":<C-u>DiffviewClose<CR>",
      { noremap = true, silent = true, buffer = args.buf, desc = "DiffviewClose" })

    -- ファイルパネル(DiffviewFiles)上でも<leader><leader>でtop<->left切り替え
    if args.match == "DiffviewFiles" then
      vim.keymap.set("n", "<leader><leader>", require("diffview_extra").toggle_file_panel_position,
        { noremap = true, silent = true, buffer = args.buf, desc = "Toggle file panel position" })
    end

    -- ファイル履歴パネル: デフォルトの<C-A-d>はmacOS+ghosttyだとOptionキーが
    -- Altとして送出されず反応しないため、gdでも同じ操作(選択中コミットを
    -- 通常のDiffviewとして開く=そのコミットの全ファイル一覧を見る)ができるようにする
    -- <S-CR>/<C-CR>も同じ操作に割り当てる（端末が拡張キーボードプロトコルに
    -- 対応していない場合は届かないことがあるため、gdをフォールバックとして残す）
    if args.match == "DiffviewFileHistory" then
      local open_in_diffview = require("diffview.actions").open_in_diffview
      vim.keymap.set("n", "gd", open_in_diffview,
        { noremap = true, silent = true, buffer = args.buf, desc = "Open entry in a diffview" })
      vim.keymap.set("n", "<S-CR>", open_in_diffview,
        { noremap = true, silent = true, buffer = args.buf, desc = "Open entry in a diffview" })
      vim.keymap.set("n", "<C-CR>", open_in_diffview,
        { noremap = true, silent = true, buffer = args.buf, desc = "Open entry in a diffview" })
    end
  end,
})

-- 「L」で開くコミット詳細(commit_log_panel)はfiletypeが汎用の"git"なので、
-- bufnameがdiffview://のものに限定してqでそのフローティング窓だけを閉じる
-- (diffview側の実装でfiletype設定 → bufname設定の順になっているため、
--  FileType発火時点ではまだbufnameが確定していない。vim.scheduleで一呼吸置いて判定する)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "git",
  callback = function(args)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then
        return
      end
      if vim.startswith(vim.api.nvim_buf_get_name(args.buf), "diffview://") then
        vim.keymap.set("n", "q", "<C-w>c",
          { noremap = true, silent = true, buffer = args.buf, desc = "Close commit log panel" })
      end
    end)
  end,
})

-- --------------------------------------------------
-- Plugin:dial.nvim
-- --------------------------------------------------
-- 切り替え対象(augend)の定義。dps-dial.vimの旧設定(decimal/date-slash/bool/case)に、
-- 日付・時刻・曜日・semver・16進などを足している。
--   decimal     : 自然数(旧設定と同じ)。負数対応のdecimal_intはハイフンをマイナスと解釈し、
--                 memo-2026-09-30のような名前で年が減る/item-5が減る等の逆転が起きるため使わない
--   hex         : 0xff -> 0x100(nrformats=が空なので標準の16進増減は効かない)
--   date        : yyyy/MM/dd, yyyy-MM-dd, 2026年9月21日(月)。月末の繰り上がりや曜日の追従あり
--   時刻        : HH:MM(23:59 -> 00:00)
--   曜日        : 月/月曜日
--   bool        : true <-> false(単語境界あり・循環。旧constantの既定と同じ)
--   semver      : 1.2.9 -> 1.2.10
--   case        : camelCase <-> snake_case(循環)
local dial_augend = require("dial.augend")

local dial_common = {
  dial_augend.integer.alias.decimal,
  dial_augend.integer.alias.hex,
  dial_augend.date.alias["%Y/%m/%d"],
  dial_augend.date.alias["%Y-%m-%d"],
  dial_augend.date.alias["%Y年%-m月%-d日(%ja)"],
  dial_augend.date.alias["%H:%M"],
  dial_augend.constant.alias.ja_weekday,
  dial_augend.constant.alias.ja_weekday_full,
  dial_augend.constant.alias.bool,
  dial_augend.semver.alias.semver,
  dial_augend.case.new({ types = { "camelCase", "snake_case" }, cyclic = true }),
}

-- filetype別のグループは、defaultに「足す」のではなく「置き換える」仕様。
-- そのため共通分をここで毎回含め直す(含めないと数字や日付が効かなくなる)
local function dial_group_with(extra)
  local list = vim.list_extend({}, dial_common)
  return vim.list_extend(list, extra)
end

local dial_config = require("dial.config")
dial_config.augends:register_group({ default = dial_common })
dial_config.augends:on_filetype({
  -- チェックボックス。[ ]と[x]の記号に単語境界はないのでword=false
  markdown = dial_group_with({
    dial_augend.constant.new({ elements = { "[ ]", "[x]" }, word = false, cyclic = true }),
  }),
  python = dial_group_with({ dial_augend.constant.alias.Bool }), -- True <-> False
})

local function dial_map(dir, mode)
  return function() require("dial.map").manipulate(dir, mode) end
end

vim.keymap.set("n", "<C-a>",  dial_map("increment", "normal"),  { noremap = true, silent = true, desc = "dial increment" })
vim.keymap.set("n", "<C-x>",  dial_map("decrement", "normal"),  { noremap = true, silent = true, desc = "dial decrement" })
vim.keymap.set("x", "<C-a>",  dial_map("increment", "visual"),  { noremap = true, silent = true, desc = "dial increment" })
vim.keymap.set("x", "<C-x>",  dial_map("decrement", "visual"),  { noremap = true, silent = true, desc = "dial decrement" })
vim.keymap.set("x", "g<C-a>", dial_map("increment", "gvisual"), { noremap = true, silent = true, desc = "dial increment (連番)" })
vim.keymap.set("x", "g<C-x>", dial_map("decrement", "gvisual"), { noremap = true, silent = true, desc = "dial decrement (連番)" })


-- --------------------------------------------------
-- Plugin:nvim-surround
-- --------------------------------------------------
--     Old text                    Command         New text
-- --------------------------------------------------------------------------------
--     surr*ound_words             ysiw)           (surround_words)
--     *make strings               ys$"            "make strings"
--     [delete ar*ound me!]        ds]             delete around me!
--     remove <b>HTML t*ags</b>    dst             remove HTML tags
--     'change quot*es'            cs'"            "change quotes"
--     <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
--     delete(functi*on calls)     dsf             function calls
require('nvim-surround').setup()

-- --------------------------------------------------
-- Plugin:gitsigns
-- --------------------------------------------------
require('gitsigns').setup{
   vim.keymap.set('n', '<Leader>gb', ':Gitsigns blame<CR>', { noremap = true, silent = true, desc = "git blame" }),
   vim.keymap.set('n', '<Leader>gp', ':Gitsigns prev_hunk<CR>', { noremap = true, silent = true, desc = "git edit prev" }),
   vim.keymap.set('n', '<Leader>gn', ':Gitsigns next_hunk<CR>', { noremap = true, silent = true, desc = "git edit next" }),
   vim.keymap.set('n', '<Leader>gB', function() require("fzf-lua").git_branches({}) end, { noremap = true, silent = true, desc = "git branch change" }),
   numhl = true,                        -- 変更行の行番号にも色を付ける
}

-- :Gitsigns blame(<Leader>gb)の見た目と操作の調整。
-- gitsignsはカーソル下と同じコミットの行を「すべて」CursorLineで塗る仕様だが、
-- CursorLineを下線にしているため(quicker節)、コミット全体が下線だらけになる。
-- blame表示中だけ、左右の窓でCursorLineを背景色の専用グループに置き換える(winhighlight)
vim.api.nvim_set_hl(0, "GitSignsBlameCommitLine", { bg = "#2a3440" })
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_gitsigns_blame", { clear = true }),
  pattern = "gitsigns-blame",
  callback = function(args)
    local remap = "CursorLine:GitSignsBlameCommitLine"
    local blm_win = vim.fn.bufwinid(args.buf)
    -- blameは元の窓をvsplitして作られるので、直前の窓(#)が元のファイルの窓
    local src_win = vim.fn.win_getid(vim.fn.winnr("#"))
    if blm_win ~= -1 then vim.wo[blm_win].winhighlight = remap end
    if src_win ~= 0 and src_win ~= blm_win then
      local orig = vim.wo[src_win].winhighlight
      vim.wo[src_win].winhighlight = orig == "" and remap or (orig .. "," .. remap)
      -- blameを閉じたら元のファイルの窓の設定を戻す
      vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(blm_win),
        once = true,
        callback = function()
          if vim.api.nvim_win_is_valid(src_win) then vim.wo[src_win].winhighlight = orig end
        end,
      })
    end
    -- blameの窓でqを押すと閉じる(gitsignsはqを割り当てていない)
    vim.keymap.set("n", "q", "<C-w>c", { buffer = args.buf, nowait = true, silent = true, desc = "close blame" })
  end,
})

-- --------------------------------------------------
-- Plugin:neovim-remote
--    install:brew install neovim-remote
--    .bashrc
--       alias vi=nvim
--       alias vim=nvim
--       if [[ -n ${EDITOR} ]]; then
--           alias vi=${EDITOR}
--           alias vim=${EDITOR}
--       fi
-- --------------------------------------------------
if vim.fn.executable('nvr') == 1 then
  vim.env.EDITOR = 'nvr -c "set bufhidden=delete" --remote-tab-wait'
end

-- --------------------------------------------------
-- Plugin:flash
-- --------------------------------------------------
-- 旧hop.nvimの<Leader>wを置き換え
-- flash.nvim公式READMEの「HopWord (hop.nvim)と同様の動き」レシピをそのまま使用。
-- 全単語頭に2文字ラベルを即時表示し、1文字目で絞り込み→2文字目で確定ジャンプする
-- （候補数に関わらず常に2打鍵になる点のみHop本来の挙動と異なる）
---@class Flash.Match
---@field label1? string 1文字目のラベル(下のlabelerで付ける)
---@field label2? string 2文字目のラベル
vim.keymap.set({ 'n', 'x', 'o' }, '<Leader>w', function()
  local Flash = require('flash')

  ---@param opts Flash.Format
  local function format(opts)
    -- 1文字目・2文字目のラベルを常に両方表示する
    return {
      { opts.match.label1, "FlashMatch" },
      { opts.match.label2, "FlashLabel" },
    }
  end

  -- scrolloff(余白)があると、画面の上下端付近へ飛んだ時にビューがスクロールして
  -- 「本当に移動できたか」が分かりにくくなる。ジャンプ中だけ0にして画面を固定する。
  -- Flash.jumpは入力待ちのループを最後まで回してから戻る同期関数なので、
  -- 戻ってきた時点で元に戻せばよい(2段階目の入れ子呼び出しも外側の中で完結する)
  local saved_scrolloff = vim.o.scrolloff
  vim.o.scrolloff = 0

  local ok, err = pcall(Flash.jump, {
    search = { mode = 'search' },
    label = { after = false, before = { 0, 0 }, uppercase = false, format = format },
    pattern = [[\<]],
    action = function(match, state)
      state:hide()
      Flash.jump({
        search = { max_length = 0 },
        highlight = { matches = false },
        label = { format = format },
        matcher = function(win)
          -- 1文字目で選ばれたラベルに絞り込む
          return vim.tbl_filter(function(m)
            return m.label == match.label and m.win == win
          end, state.results)
        end,
        labeler = function(matches)
          for _, m in ipairs(matches) do
            m.label = m.label2 -- 2文字目のラベルを使う
          end
        end,
      })
    end,
    labeler = function(matches, state)
      local labels = state:labels()
      for m, match in ipairs(matches) do
        match.label1 = labels[math.floor((m - 1) / #labels) + 1]
        match.label2 = labels[(m - 1) % #labels + 1]
        match.label = match.label1
      end
    end,
  })

  -- 先に再描画して位置を確定させてから戻す。戻した後のredrawで余白分だけ
  -- スクロールされるのを避けるため。次にカーソルを動かした時点で余白は再び効く
  vim.cmd("redraw")
  vim.o.scrolloff = saved_scrolloff
  if not ok then
    error(err, 0)
  end

  -- flashの規定動作（検索文字入力→ラベルジャンプ）を試したい場合は
  -- 上のFlash.jump(...)ブロックをコメントアウトし、下記のコメントを外して使う
  -- require('flash').jump()
end, { noremap = true, silent = true, desc = "Flash Word (Hop-like)" })

-- --------------------------------------------------
-- Plugin:neo-tree
-- --------------------------------------------------
-- bind_to_cwd=false: neo-treeのルートを動かしてもVimのcwd(tcd)を書き換えない。
-- 既定のtrueだと、reveal_force_cwdやツリー内の`.`/`<bs>`でルートが変わるたびに
-- タブ全体のcwdが勝手に変わってしまう。副作用としてルートはcwdに追従しなくなる
-- (前回のルートが残る)ので、戻したい時はツリー内で<bs>を使う。
-- どのソースに切り替えてもcwdを触らないよう3つとも指定する
-- sources: document_symbolsは既定で無効なので、既定の3つと合わせて明示する
require('neo-tree').setup{
   sources = { "filesystem", "buffers", "git_status", "document_symbols" },
   buffers = { bind_to_cwd = false },
   git_status = { bind_to_cwd = false },
   -- document_symbolsはノードが閉じた状態で描画され、Javaだとクラス名1行しか見えない。
   -- 対象ファイルが変わった最初の描画でだけ全展開する(毎回やると手で閉じた状態が
   -- 戻されるうえ、expand_all_nodes自身の再描画でafter_renderが再発火してループする)
   event_handlers = {
     {
       event = "after_render",
       handler = function(state)
         if state.name ~= "document_symbols" or state._auto_expanded_path == state.path then
           return
         end
         state._auto_expanded_path = state.path
         require("neo-tree.sources.common.commands").expand_all_nodes(state)
       end,
     },
   },
   filesystem = {
     bind_to_cwd = false,
     window = {
       width = 30,
     },
     filtered_items = {
       hide_dotfiles = false,
       never_show = {
          ".git",
          ".DS_Store",
        },
     },
   },
   vim.keymap.set('n', '<Leader>s', ':Neotree reveal_force_cwd position=left toggle<CR>', { noremap = true, silent = true, desc = "neotree left" }),
   vim.keymap.set('n', '<Leader>S', ':Neotree reveal_force_cwd position=top toggle<CR>', { noremap = true, silent = true, desc = "neotree top" }),
}

-- <Leader><Leader>: 左側/上部に表示中ならその間をトグルし、
-- それ以外（閉じている等）は従来通りモーダル表示をトグルする
local function neotree_toggle_or_reposition()
  local manager = require("neo-tree.sources.manager")
  local renderer = require("neo-tree.ui.renderer")
  local state = manager.get_state("filesystem")

  if renderer.window_exists(state) and state.current_position == "left" then
    require("neo-tree.command").execute({ action = "close", position = "left" })
    require("neo-tree.command").execute({ position = "top", reveal_force_cwd = true })
  elseif renderer.window_exists(state) and state.current_position == "top" then
    require("neo-tree.command").execute({ action = "close", position = "top" })
    require("neo-tree.command").execute({ position = "left", reveal_force_cwd = true })
  else
    vim.cmd("Neotree reveal_force_cwd position=float toggle")
  end
end
vim.keymap.set('n', '<Leader><Leader>', neotree_toggle_or_reposition,
  { noremap = true, silent = true, desc = "neotree float / left<->top" })

-- --------------------------------------------------
-- Plugin:hlchunk
-- --------------------------------------------------
require('hlchunk').setup{
    indent = {
        enable = true
    },
}

-- --------------------------------------------------
-- Plugin:fzf-lua
-- --------------------------------------------------
-- TIPS: https://github.com/ibhagwan/fzf-lua/wiki/Advanced
-- src:  https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/providers/grep.lua

-- fzf-lua既定のヘッダ(`:: <ctrl-g> to Fuzzy Search, cwd: ...`)と同じ配色・書式に
-- 揃えるためのヘルパ。FzfLuaHeaderBind/FzfLuaHeaderTextをANSI化して使う。
-- ansi_from_hlは未定義グループなら素の文字列を返すので、fzf-lua側で名前が
-- 変わっても色が付かなくなるだけで落ちない
local fzf_hdr = {}

-- アクションの説明。キー=Bind色、説明=Text色
function fzf_hdr.bind(key, to)
  local utils = require("fzf-lua.utils")
  return ("<%s> to %s"):format(
    utils.ansi_from_hl("FzfLuaHeaderBind", key),
    utils.ansi_from_hl("FzfLuaHeaderText", to))
end

-- アクションを伴わない単なる案内。説明側は着色しない
function fzf_hdr.hint(key, to)
  return ("<%s> %s"):format(
    require("fzf-lua.utils").ansi_from_hl("FzfLuaHeaderBind", key), to)
end

function fzf_hdr.split_hint()
  return fzf_hdr.hint("ctrl-x/v/s", "split/vsplit/tab")
end

-- live_grepのヘッダでcwdより後ろにヒントを出すための指定。
-- headerを直接指定すると<ctrl-g>のラベルがFuzzy/Regexで切り替わらなくなるため、
-- 使っていないref見出し枠を_headersの最後に足して間借りする。
-- ref枠の値はText色(赤)で包まれるので、先頭にリセットを入れて素の色に戻す
function fzf_hdr.after_cwd_opts()
  return {
    _headers = { "actions", "cwd", "ref" },
    ref = "\27[0m" .. fzf_hdr.split_hint(),
    ref_header_txt = "",
  }
end

-- 一覧にサイズ・更新日時・作成日時のカラムを付けるためのヘルパ。
--
-- Luaの %-Ns はバイト数で詰めるため、日本語ファイル名があると桁がずれる
-- (例: "メモ.txt" は10バイトだが表示幅は8)。vim.fn.strdisplaywidth()で
-- 表示幅を数えて揃える。
-- 名前と各カラムの区切りにはfzf-luaと同じ不可視スペース(U+2002)を使い、
-- --delimiter/--nth で検索対象を名前の列だけに限定する。
local fzf_cols = {}

function fzf_cols.pad(s, w)
  return s .. string.rep(" ", math.max(w - vim.fn.strdisplaywidth(s), 0))
end

function fzf_cols.rpad(s, w)
  return string.rep(" ", math.max(w - vim.fn.strdisplaywidth(s), 0)) .. s
end

function fzf_cols.size(st)
  if not st or st.type == "directory" then
    return "-"
  end
  local n, units, i = st.size, { "B", "K", "M", "G" }, 1
  while n >= 1024 and i < #units do
    n, i = n / 1024, i + 1
  end
  return i == 1 and ("%dB"):format(n) or ("%.1f%s"):format(n, units[i])
end

-- WSL等のファイルシステムではbirthtimeが取れずsec=0になることがあるので"-"にする
function fzf_cols.time(t)
  return (t and t.sec and t.sec > 0) and os.date("%Y-%m-%d %H:%M", t.sec) or "-"
end

-- 列レイアウト: name <nbsp> size(7右寄せ) modified(16) <nbsp> created
-- nbspは不可視の区切り。1列目=名前、3列目=createdとして検索対象を選べる。
--
-- name_ansi: 着色済みの名前 / name_plain: 幅計算用の素の名前
-- created: 明示したい場合の文字列(g,mはファイル名の日付を渡す)。
--          省略時はbirthtimeを使う
function fzf_cols.row(name_ansi, name_plain, name_w, st, created)
  local utils = require("fzf-lua.utils")
  local dim = function(s) return utils.ansi_from_hl("Comment", s) end
  return name_ansi
    .. string.rep(" ", math.max(name_w - vim.fn.strdisplaywidth(name_plain), 0))
    .. utils.nbsp
    .. dim(fzf_cols.rpad(fzf_cols.size(st), 7))
    .. "  " .. dim(fzf_cols.pad(fzf_cols.time(st and st.mtime), 16))
    .. "  " .. utils.nbsp .. dim(created or fzf_cols.time(st and st.birthtime))
end

-- 検索対象の列を指定する。既定は名前(1列目)のみ
function fzf_cols.fzf_opts(nth)
  local utils = require("fzf-lua.utils")
  return { ["--delimiter"] = ("[%s]"):format(utils.nbsp), ["--nth"] = nth or "1" }
end

-- カラム見出し。ヘッダ行として一覧の上に出す
function fzf_cols.header(name_w, created_label)
  local utils = require("fzf-lua.utils")
  return utils.ansi_from_hl("Comment",
    fzf_cols.pad("", name_w + 1) .. fzf_cols.rpad("size", 7) .. "  "
    .. fzf_cols.pad("modified", 16) .. "  " .. utils.nbsp .. (created_label or "created"))
end

local fzf_lua_files_cmd = "fd --color=never --type f --hidden --follow --exclude .git "

-- 最近使ったファイル
_G.fzf_mru = function(mode)
  local fzf_lua = require("fzf-lua")
  mode = mode or "mru"
  fzf_lua.fzf_exec(function(cb)
    for _, path in ipairs(vim.fn[("mr#%s#list"):format(mode)]()) do
      local entry = fzf_lua.make_entry.file(path, { file_icons = true, color_icons = true })
      cb(entry)
    end
    cb()
  end, {
    prompt = ("%s> "):format(mode:upper()),
    file_icons = true,
    color_icons = true,
    actions = {
      ["default"] = fzf_lua.actions.file_edit,
      ["ctrl-x"]  = fzf_lua.actions.file_split,
      ["ctrl-v"]  = fzf_lua.actions.file_vsplit,
      ["ctrl-s"]  = fzf_lua.actions.file_tabedit,
      ["ctrl-q"]  = fzf_lua.actions.file_sel_to_qf,
      ["ctrl-l"]  = fzf_lua.actions.file_sel_to_ll, -- location listへ
    },
    previewer = "builtin",
    fzf_opts = {
      ["--no-sort"] = "",
    },
  })
end

-- メモ一覧(g,m)は memo セクション側で定義している

-- --------------------------------------------------
-- お気に入り(sw)
--   fav.txtにファイルとディレクトリを1行1件で書く(~記法可)。
--   ディレクトリを決定するとneo-treeをフロートで開きlcdする。
--   以前はcatをfzf_execへ生で流していたため file_icons/color_icons が
--   効いていなかった(その経路はfn_transformを通さないと適用されない)ので、
--   deviconsで自前にアイコンを付ける
-- --------------------------------------------------
local fav_file = vim.fn.expand("~/.config/nvim/fav.txt")

-- 一覧の絞り込み。true=ディレクトリのみ / false=全部(既定)
local fav_dirs_only = false

-- fav.txtを読み、1行を{raw(元の表記), path(実パス), kind}に正規化する
local function fav_entries()
  local list = {}
  for _, raw in ipairs(vim.fn.filereadable(fav_file) == 1 and vim.fn.readfile(fav_file) or {}) do
    local line = vim.trim(raw)
    if line ~= "" then
      local p = vim.fn.expand(line)
      local kind = vim.fn.isdirectory(p) == 1 and "dir"
        or vim.fn.filereadable(p) == 1 and "file"
        or "missing"
      list[#list + 1] = { raw = line, path = p, kind = kind }
    end
  end
  return list
end

-- 表示文字列を作る。ディレクトリは末尾/とフォルダアイコンで一目で分かるようにする
local function fav_display(e)
  local utils = require("fzf-lua.utils")
  if e.kind == "dir" then
    -- fav.txt側が末尾/付きで書かれていても//にならないようにする
    return utils.ansi_from_hl("Directory", " " .. (e.raw:gsub("/*$", "")) .. "/")
  elseif e.kind == "missing" then
    return utils.ansi_from_hl("DiagnosticError", "  " .. e.raw .. "  [missing]")
  end
  local dev = require("nvim-web-devicons")
  local icon, hl = dev.get_icon(vim.fn.fnamemodify(e.path, ":t"),
    vim.fn.fnamemodify(e.path, ":e"), { default = true })
  return utils.ansi_from_hl(hl, icon or "") .. " " .. e.raw
end

-- ディレクトリのプレビューをezaのツリー表示にする。
-- fzf-luaのbuiltinプレビューアはディレクトリを固定で `ls -la` するため
-- (previewer/builtin.lua)、parse_entryを差し替えてコマンドだけ入れ替える。
-- 出力はnvim_open_termへ流されるので--color=alwaysのANSIがそのまま反映される。
-- ezaが無い環境(会社のWSL等で未導入の間)は既定のls -laのままにする。
local fav_previewer = require("fzf-lua.previewer.builtin").buffer_or_file:extend()

function fav_previewer:parse_entry(entry_str, cb)
  ---@diagnostic disable-next-line: undefined-field
  local entry = fav_previewer.super.parse_entry(self, entry_str, cb)
  if entry and entry.path
      and vim.fn.isdirectory(entry.path) == 1
      and vim.fn.executable("eza") == 1 then
    entry.cmd = {
      "eza", "--tree",
      "--level=2",                 -- 2階層まで
      "--color=always",            -- パイプ越しでも色を出す
      "--icons=always",            -- 同上(アイコン)
      "--group-directories-first", -- ディレクトリを先に
      "--all",                     -- ドットファイルも出す
      "--ignore-glob=.git",        -- .gitだけは除く
      entry.path,
    }
  end
  return entry
end

-- ディレクトリを開く。neo-treeをフロートで出し、lcdでカレントを移す。
-- ファイルを選ばずに閉じた場合だけ元のカレントへ戻す。
--
-- ディレクトリを開く。lcdでカレントを移し、そのままsf相当のファイル一覧を出す。
-- lcdはウィンドウローカルなので、閉じかけのfzfウィンドウで実行すると
-- そのまま捨てられてしまう。scheduleして復帰後のウィンドウに対して行う。
local function fav_open_dir(path)
  vim.schedule(function()
    vim.cmd("lcd " .. vim.fn.fnameescape(path))
    -- cwdは渡さない(sfと同じくカレント基準)
    require("fzf-lua").files({})
  end)
end

-- dirs_only を渡すと絞り込み状態を上書きして開く(sw=全部 / sW=ディレクトリのみ)。
-- 省略時は現在の状態のまま開き直す(ctrl-oのトグルやリフレッシュ用)
_G.fzf_fav_file_list = function(dirs_only)
  if dirs_only ~= nil then
    fav_dirs_only = dirs_only
  end
  local fzf_lua = require("fzf-lua")
  local utils = require("fzf-lua.utils")
  local all = fav_entries()

  -- ctrl-rでディレクトリのみに絞る
  local list = {}
  for _, e in ipairs(all) do
    if not fav_dirs_only or e.kind == "dir" then
      list[#list + 1] = e
    end
  end

  -- 名前カラムの幅は実データの最大に合わせる(長すぎる場合は打ち切る)
  local name_w = 0
  for _, e in ipairs(list) do
    local w = vim.fn.strdisplaywidth(utils.strip_ansi_coloring(fav_display(e)))
    name_w = math.max(name_w, w)
  end
  name_w = math.min(name_w, 70)

  -- 表示文字列 -> エントリ の対応表。選択値はANSIを落としてから引く
  local by_display = {}
  local items = {}
  for _, e in ipairs(list) do
    local name = fav_display(e)
    local d = fzf_cols.row(name, utils.strip_ansi_coloring(name), name_w, vim.uv.fs_stat(e.path))
    by_display[utils.strip_ansi_coloring(d)] = e
    items[#items + 1] = d
  end

  local function picked(selected)
    return selected and selected[1] and by_display[utils.strip_ansi_coloring(selected[1])]
  end

  fzf_lua.fzf_exec(items, {
    prompt = "FAV> ",
    -- ctrl-rのラベルは「押すとどうなるか」を示す(fzf-lua既定の流儀に合わせる)
    header = ":: " .. table.concat({
      fzf_hdr.bind("ctrl-e", "edit fav.txt"),
      fzf_hdr.bind("ctrl-o", fav_dirs_only and "Show all" or "Dirs only"),
      fzf_hdr.split_hint(),
    }, "|") .. ", filter: " ..
      utils.ansi_from_hl("FzfLuaHeaderText", fav_dirs_only and "dirs" or "all")
      .. "\n" .. fzf_cols.header(name_w),
    previewer = { _ctor = function() return fav_previewer end },
    -- 表示文字列は自前でアイコンを付けているため、そのままではプレビューアが
    -- 「アイコン込みの文字列」をパスとして解決しようとして失敗する。
    -- _fmt.from で実パスへ戻してから解決させる
    _fmt = {
      from = function(entry)
        local e = by_display[utils.strip_ansi_coloring(entry)]
        return e and e.path or entry
      end,
    },
    -- --nth/--delimiterでカラム部分(サイズ等)が検索に引っかからないようにする
    fzf_opts = vim.tbl_extend("force",
      { ["--no-sort"] = "", ["--header-lines"] = 0 }, fzf_cols.fzf_opts()),
    actions = {
      ["default"] = function(selected)
        local e = picked(selected)
        if not e then
          return
        end
        if e.kind == "dir" then
          fav_open_dir(e.path)
        elseif e.kind == "missing" then
          vim.notify("存在しません: " .. e.raw, vim.log.levels.WARN)
        else
          vim.cmd("edit " .. vim.fn.fnameescape(e.path))
        end
      end,
      ["ctrl-e"] = function()
        vim.cmd("split " .. vim.fn.fnameescape(fav_file))
      end,
      -- 絞り込みのトグルは g,m の並び替えと同じ ctrl-o に揃えている
      ["ctrl-o"] = function()
        fav_dirs_only = not fav_dirs_only
        vim.schedule(_G.fzf_fav_file_list)
      end,
      -- split系は開く対象がファイルのときだけ意味がある
      ["ctrl-x"] = function(selected)
        local e = picked(selected)
        if e and e.kind == "file" then vim.cmd("split " .. vim.fn.fnameescape(e.path)) end
      end,
      ["ctrl-v"] = function(selected)
        local e = picked(selected)
        if e and e.kind == "file" then vim.cmd("vsplit " .. vim.fn.fnameescape(e.path)) end
      end,
      ["ctrl-s"] = function(selected)
        local e = picked(selected)
        if e and e.kind == "file" then vim.cmd("tabedit " .. vim.fn.fnameescape(e.path)) end
      end,
    },
  })
end

-- 現在のファイル / ディレクトリをお気に入りに追加する
vim.api.nvim_create_user_command("FavAdd", function(cmd)
  local target = cmd.args ~= "" and cmd.args or vim.fn.expand("%:p")
  if target == "" then
    vim.notify("対象がありません", vim.log.levels.WARN)
    return
  end
  -- ~記法で保存して環境差を吸収する
  local raw = vim.fn.fnamemodify(target, ":p"):gsub("^" .. vim.pesc(vim.env.HOME), "~")
  raw = raw:gsub("/$", "")
  for _, e in ipairs(fav_entries()) do
    if e.raw == raw then
      vim.notify("追加済みです: " .. raw, vim.log.levels.INFO)
      return
    end
  end
  vim.fn.writefile({ raw }, fav_file, "a")
  vim.notify("お気に入りに追加: " .. raw)
end, { nargs = "?", complete = "file", desc = "現在のファイル/ディレクトリをfav.txtへ追加" })

-- --------------------------------------------------
-- org_function ランチャ(sx)
--   lua/org_function.lua の公開関数と @cmd 宣言、下の org_common_entries を一覧し、選んだものを
--   バッファへ適用する。ビジュアルで行選択していればその範囲だけが対象。
--   書き方は org_function.lua の冒頭コメントを参照。
-- --------------------------------------------------

-- sxの、MacとWSLで共通の項目(init.luaは共通、lua/org_function.luaはマシンごとに別でWSLは別の内容のため)。
-- マシンごとの項目は各マシンの lua/org_function.lua に書く。同じnameがあればそちらを優先する(WSLだけ中身を変えられる)。
--   name: 物理名(一覧の見出し・ユーザーコマンド名。大文字で始める) label: 論理名(@label)
--   fn: lines -> lines の関数(プレビューで実行されるので、バッファに触れない純粋な関数にする。nilを返すと変更しない)
--   sh: シェルコマンド(@sh。選択行を標準入力に流し、標準出力で差し替える)。MacとWSLの両方で動くものだけ
--   preview: shを、sxのプレビューで実行してよいか(@preview。副作用が無いものだけ)
local org_common_entries = {
  { name = "Trimtrailing", label = "行末の空白・タブを削除",
    fn = function(lines)
      local out = {}
      for _, line in ipairs(lines) do
        -- Vimの\sと同じく半角スペースとタブだけ(全角スペースは残す)
        out[#out + 1] = (line:gsub("[ \t]+$", ""))
      end
      return out
    end },
}

-- ソースを1行ずつ見て、関数の論理名(@label)と@cmd宣言を集める。
-- 「@labelの次の行が関数」とは限らない(説明コメントが挟まる)ので、
-- 直近の@labelを覚えておいて function M.<名前> が出た時点で結びつける
local function org_fn_entries()
  -- org_function.luaが無い・読めないマシンでも、共通の項目だけで開けるようにする
  local ok, mod = pcall(require, "org_function")
  if not ok or type(mod) ~= "table" then mod = {} end
  local src_path = vim.api.nvim_get_runtime_file("lua/org_function.lua", false)[1]
  local src = src_path and table.concat(vim.fn.readfile(src_path), "\n") or ""

  local labels, cmds = {}, {}
  local pending, cur = nil, nil
  for line in src:gmatch("[^\n]*") do
    local cname = line:match("@cmd%s+([%w_]+)")
    local label = line:match("@label%s+(.+)$")
    local sh = line:match("@sh%s+(.+)$")
    local fname = line:match("^function%s+M%.([%w_]+)")
    if cname then
      cur = { name = cname, kind = "cmd" }
    elseif cur and label then
      cur.label = vim.trim(label)
    elseif cur and line:match("@preview%s*$") then
      cur.preview = true -- 副作用が無いので、sxのプレビューで実行してよい
    elseif cur and sh then
      cur.sh = vim.trim(sh)
      cmds[#cmds + 1] = cur
      cur = nil
    elseif label then
      pending = vim.trim(label)
    elseif fname then
      labels[fname] = pending
      pending = nil
    end
  end

  local list = {}
  for name, fn in pairs(mod) do
    if type(fn) == "function" then
      list[#list + 1] = { name = name, kind = "lua", label = labels[name] or "", fn = fn }
    end
  end
  for _, c in ipairs(cmds) do
    list[#list + 1] = c
  end
  -- 共通の項目を足す。org_function.luaに同じnameがあればそちらを使い、種別に(上書き)を付ける
  local by_name = {}
  for _, e in ipairs(list) do by_name[e.name] = e end
  for _, c in ipairs(org_common_entries) do
    if by_name[c.name] then
      by_name[c.name].kind = by_name[c.name].kind .. "(上書き)"
      if by_name[c.name].label == "" then by_name[c.name].label = c.label or "" end -- @labelが無ければ共通の論理名
    else
      list[#list + 1] = { name = c.name, kind = "共通", label = c.label or "", fn = c.fn, sh = c.sh, preview = c.preview }
    end
  end
  table.sort(list, function(a, b) return a.name < b.name end)
  return list
end

-- 対象行を差し替える。first/lastは0-indexedのexclusive end(nvim_buf_get_lines準拠)。
-- bufはsxを押した時点のバッファ。アクションはfzfを閉じた後に走るため、
-- カレント任せにすると別のバッファへ書いてしまう
-- entryをlinesに適用した結果の行を返す(バッファには触れない。sxのプレビューでも使う)。
-- 失敗したらnilとエラーメッセージ。関数がnil(何もしない)を返したらnilだけ。
-- timeoutは@cmdの実行時間の上限(ms)
local function org_compute(entry, lines, timeout)
  if entry.sh then
    local obj = vim.system({ "sh", "-c", entry.sh },
      { stdin = table.concat(lines, "\n") .. "\n", text = true, timeout = timeout }):wait()
    if obj.code ~= 0 then
      return nil, ("%s 失敗: %s"):format(entry.name, vim.trim(obj.stderr or ""))
    end
    return vim.split((obj.stdout or ""):gsub("\n$", ""), "\n", { plain = true })
  end
  local ok, r = pcall(entry.fn, vim.deepcopy(lines))
  if not ok then
    return nil, ("%s でエラー: %s"):format(entry.name, tostring(r))
  end
  return r -- nilは「何もしない」の意
end

local function org_apply(entry, buf, first, last)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)
  local result, err = org_compute(entry, lines)
  -- 失敗時・nil(何もしない)のときはバッファに触れない
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end
  if result == nil then
    return
  end

  -- 1回のset_linesなので undo も1回で戻る
  vim.api.nvim_buf_set_lines(buf, first, last, false, result)
  vim.notify(("%s: %d行 -> %d行"):format(entry.name, #lines, #result))
end

-- sxのプレビュー: 選んでいる関数を対象行に適用した結果を、差分(既定)か変換後の全文で見せる。
-- バッファには書き込まない。重くならないよう対象の先頭ORG_PREVIEW_MAX行だけで計算し、結果は関数ごとに覚えておく。
-- @cmd(シェル)は副作用があり得るので、@previewを付けたものだけ実行する
local ORG_PREVIEW_MAX = 1000
local org_diff_ns = vim.api.nvim_create_namespace("org_function_diff")

-- 表示幅でwidthに収める(はみ出す分は…で切る)。全角は2桁として数える
local function org_fit(s, width)
  s = s:gsub("\t", "    ")
  if vim.fn.strdisplaywidth(s) > width then
    local out = ""
    for _, ch in ipairs(vim.fn.split(s, "\\zs")) do
      if vim.fn.strdisplaywidth(out .. ch) > width - 1 then break end
      out = out .. ch
    end
    s = out .. "…"
  end
  return s .. string.rep(" ", width - vim.fn.strdisplaywidth(s))
end

-- 変換前(a)と変換後(b)を左右に並べた行と、色付けの位置を作る。
-- vim.text.diffで対応する行を求め、変更は両側、削除は左だけ、追加は右だけに色を付ける
local function org_side_by_side(a, b, width)
  local col = math.max(10, math.floor((width - 3) / 2))
  local rows = {} -- { left, right, left_hl, right_hl }
  local function add(l, r, lhl, rhl) rows[#rows + 1] = { l, r, lhl, rhl } end

  local hunks = vim.text.diff(table.concat(a, "\n") .. "\n", table.concat(b, "\n") .. "\n", { result_type = "indices" }) --[[@as integer[][] ]]
  local ia, ib = 1, 1
  for _, h in ipairs(hunks) do
    local sa, ca, _, cb = h[1], h[2], h[3], h[4]
    -- 件数0の側は、その行の「後ろ」に挿入/削除される意味なので、そこまでが変更なし
    local until_a = ca == 0 and sa or sa - 1
    while ia <= until_a do
      add(a[ia], b[ib]) ia, ib = ia + 1, ib + 1
    end
    for k = 0, math.max(ca, cb) - 1 do
      if k < ca and k < cb then
        add(a[ia], b[ib], "DiffChange", "DiffChange") ia, ib = ia + 1, ib + 1
      elseif k < ca then
        add(a[ia], nil, "DiffDelete", nil) ia = ia + 1
      else
        add(nil, b[ib], nil, "DiffAdd") ib = ib + 1
      end
    end
  end
  while ia <= #a or ib <= #b do
    add(a[ia], b[ib]) ia, ib = ia + 1, ib + 1
  end

  local lines = { org_fit("変換前", col) .. " │ " .. org_fit("変換後", col), string.rep("─", col) .. "─┼─" .. string.rep("─", col) }
  local marks = { { 0, 0, #lines[1], "Title" }, { 1, 0, #lines[2], "Comment" } }
  for _, row in ipairs(rows) do
    local left, right = org_fit(row[1] or "", col), org_fit(row[2] or "", col)
    local line = left .. " │ " .. right
    local lnum = #lines
    lines[#lines + 1] = line
    if row[3] then marks[#marks + 1] = { lnum, 0, #left, row[3] } end
    if row[4] then marks[#marks + 1] = { lnum, #left + #" │ ", #line, row[4] } end
    marks[#marks + 1] = { lnum, #left, #left + #" │ ", "Comment" }
  end
  return lines, marks, #hunks == 0
end

local org_state -- 開いているsxのプレビューの状態(org_function_listで作り直す)
local org_previewer = require("fzf-lua.previewer.builtin").base:extend()
function org_previewer:new(o, opts)
  org_previewer.super.new(self, o, opts)
  setmetatable(self, org_previewer)
  org_state.previewer = self -- ctrl-/で表示を切り替えたときに描き直すため
  return self
end
function org_previewer:populate_preview_buf(entry_str)
  local st = org_state
  st.last_entry = entry_str
  local name = require("fzf-lua.utils").strip_ansi_coloring(entry_str):match("^%s*(%S+)")
  local e = name and st.by_name[name]
  if not e then return end

  -- 結果の計算(関数ごとに1回だけ)
  local r = st.cache[name]
  if not r then
    r = {}
    if e.sh and not e.preview then
      r.msg = { "シェルのコマンドのためプレビューしません(@previewを付けると実行します)", "", "$ " .. e.sh }
    else
      local out, err = org_compute(e, st.lines, 3000)
      if err then
        r.msg = vim.split(err, "\n", { plain = true })
      elseif out == nil then
        r.msg = { "変更なし(関数がnilを返しました)" }
      else
        r.out = out
      end
    end
    st.cache[name] = r
  end

  local buf = self:get_tmp_buffer()
  local lines, syntax, marks, same
  if r.msg then
    lines = r.msg
  elseif st.mode == "diff" then
    -- 左右に並べた差分(変換前 │ 変換後)。幅はプレビュー窓に合わせる
    local winid = self.win.preview_winid
    local width = (winid and vim.api.nvim_win_is_valid(winid)) and vim.api.nvim_win_get_width(winid) or 80
    lines, marks, same = org_side_by_side(st.lines, r.out, width)
  else
    lines = r.out
    syntax = st.ft
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  for _, m in ipairs(marks or {}) do
    vim.api.nvim_buf_set_extmark(buf, org_diff_ns, m[1], m[2], { end_col = m[3], hl_group = m[4] })
  end
  if syntax and syntax ~= "" then
    local lang = vim.treesitter.language.get_lang(syntax)
    if not (lang and pcall(vim.treesitter.start, buf, lang)) then
      vim.bo[buf].syntax = syntax
    end
  end
  self:set_preview_buf(buf)
  local count = r.out and ("%d行 -> %d行"):format(#st.lines, #r.out) or ""
  self.win:update_preview_title((" %s %s %s%s "):format(
    name, st.mode == "diff" and (same and "[差分・変更なし]" or "[差分]") or "[全文]", count, st.truncated and (" (先頭%d行のみ)"):format(ORG_PREVIEW_MAX) or ""))
  self.win:update_preview_scrollbar()
end

local function org_function_list(first, last)
  local fzf_lua = require("fzf-lua")
  local utils = require("fzf-lua.utils")
  local buf = vim.api.nvim_get_current_buf()
  local list = org_fn_entries()
  if #list == 0 then
    vim.notify("org_function に関数がありません", vim.log.levels.WARN)
    return
  end

  -- カラム: 関数名 / 種別 / 論理名
  local nw, kw = 0, 0
  for _, e in ipairs(list) do
    nw = math.max(nw, vim.fn.strdisplaywidth(e.name))
    kw = math.max(kw, vim.fn.strdisplaywidth(e.kind))
  end

  -- 照合は行全体ではなく先頭の関数名で行う。行全体をキーにすると
  -- 空白やANSIの扱いが少しでも違った時点で引けなくなる
  local by_name, items = {}, {}
  for _, e in ipairs(list) do
    by_name[e.name] = e
    items[#items + 1] = fzf_cols.pad(e.name, nw + 2)
      .. utils.ansi_from_hl("Comment", fzf_cols.pad(e.kind, kw + 2))
      .. utils.ansi_from_hl("Comment", e.label or "")
  end

  -- lastは nvim_buf_get_lines 準拠で -1 が「最後まで」を意味する
  local target = (last >= 0) and ("選択 %d-%d行"):format(first + 1, last) or "バッファ全体"

  -- プレビューの状態。対象行は先頭ORG_PREVIEW_MAX行だけ使う
  local target_lines = vim.api.nvim_buf_get_lines(buf, first, last, false)
  org_state = {
    by_name = by_name,
    lines = vim.list_slice(target_lines, 1, ORG_PREVIEW_MAX),
    truncated = #target_lines > ORG_PREVIEW_MAX,
    ft = vim.bo[buf].filetype,
    mode = "diff",
    cache = {},
  }

  fzf_lua.fzf_exec(items, {
    prompt = "FUNC> ",
    header = ":: " .. table.concat({
      fzf_hdr.bind("enter", "run"),
      fzf_hdr.bind("ctrl-/", "diff/full"),
      fzf_hdr.bind("ctrl-e", "edit org_function.lua"),
    }, "|") .. ", target: " ..
      utils.ansi_from_hl("FzfLuaHeaderText", target)
      .. "\n" .. utils.ansi_from_hl("Comment",
        fzf_cols.pad("name", nw + 2) .. fzf_cols.pad("kind", kw + 2) .. "label"),
    previewer = { _ctor = function() return org_previewer end },
    fzf_opts = { ["--no-sort"] = "" },
    actions = {
      -- プレビューを差分と変換後の全文で切り替える(fzfは閉じない)
      ["ctrl-/"] = {
        fn = function()
          org_state.mode = org_state.mode == "diff" and "full" or "diff"
          if org_state.previewer and org_state.last_entry then
            org_state.previewer:display_entry(org_state.last_entry)
          end
        end,
        exec_silent = true,
      },
      ["default"] = function(selected)
        if not (selected and selected[1]) then
          return
        end
        local name = utils.strip_ansi_coloring(selected[1]):match("^%s*(%S+)")
        local e = name and by_name[name]
        if not e then
          vim.notify("関数を特定できませんでした: " .. tostring(name), vim.log.levels.ERROR)
          return
        end
        -- fzfが閉じ切ってから適用する
        vim.schedule(function() org_apply(e, buf, first, last) end)
      end,
      ["ctrl-e"] = function()
        local src_path = vim.api.nvim_get_runtime_file("lua/org_function.lua", false)[1]
        if src_path then
          vim.cmd("split " .. vim.fn.fnameescape(src_path))
        end
      end,
    },
  })
end

-- 一覧(sx)からだけでなく :Convwiki のようにコマンドでも呼べるようにする。
-- org_functionの関数はlines->linesの純粋な関数でバッファを触らないため、
-- ここでバッファへの適用を被せてユーザーコマンドとして登録する。
--   :Convwiki        -> バッファ全体
--   :'<,'>Convwiki   -> 選択範囲(範囲指定つきなら任意の行範囲)
local function org_register_commands()
  for _, e in ipairs(org_fn_entries()) do
    pcall(vim.api.nvim_create_user_command, e.name, function(a)
      local buf = vim.api.nvim_get_current_buf()
      -- a.rangeは範囲指定が無ければ0。既定はバッファ全体とする
      local first, last = 0, -1
      if a.range > 0 then
        first, last = a.line1 - 1, a.line2
      end
      org_apply(e, buf, first, last)
    end, { range = true, desc = (e.label ~= "" and e.label or e.name) })
  end
end

org_register_commands()

-- org_function.lua を編集したあと、再起動せずに読み直す
vim.api.nvim_create_user_command("OrgFuncReload", function()
  package.loaded["org_function"] = nil
  local ok, err = pcall(org_register_commands)
  if ok then
    vim.notify("org_function を再読み込みしました")
  else
    vim.notify("再読み込み失敗: " .. tostring(err), vim.log.levels.ERROR)
  end
end, { desc = "org_function を再読み込みしてコマンドを再登録" })

vim.keymap.set("n", "sx", function()
  org_function_list(0, -1)
end, { noremap = true, silent = true, desc = "org_function 実行(全体)" })

vim.keymap.set("x", "sx", function()
  -- ビジュアルを抜けないと '< '> が確定しない
  vim.cmd("normal! \27")
  org_function_list(vim.fn.line("'<") - 1, vim.fn.line("'>"))
end, { noremap = true, silent = true, desc = "org_function 実行(選択行)" })

local actions = require'fzf-lua.actions'

-- fzfの入力(検索語)の履歴をpicker別のファイルに残す(fzf-lua組み込みの仕組み。ファイル名はpicker名)。
-- Enterで確定した時の入力だけが記録される。履歴があるpickerではfzfがctrl-p/ctrl-nを
-- 履歴の前/次に自動で割り当てる(候補の上下移動はctrl-k/ctrl-j)
vim.g.fzf_history_dir = vim.fn.stdpath("data") .. "/fzf-lua-history"

-- カーソル下の語を使うpicker用のプロンプト。grep系と同じ見た目(FzfLuaLivePrompt色の「語 > 」)で、
-- 何の語で検索/参照しているかを入力欄の左に表示する。expandはキー押下時点で評価するため関数にしている
local function fzf_word_prompt(what)
  local word = vim.fn.expand(what or "<cword>")
  return (require("fzf-lua.utils").ansi_from_hl("FzfLuaLivePrompt", word)) .. " > "
end

-- visual modeで選択中の文字列(複数行選択時は1行目のみ。前後の空白は除く)。未選択相当なら空文字
local function fzf_visual_text()
  return vim.trim(vim.split(require("fzf-lua.utils").get_visual_selection() or "", "\n")[1] or "")
end

-- nameでファイル名を検索する(fdのパターンに渡す。大文字小文字は区別しない正規表現)。
-- 「/」を含む場合はfdがファイル名部分だけでは照合できないため、--full-pathでパス全体と照合する
local function fzf_files_by_name(name)
  local utils = require("fzf-lua.utils")
  local full_path = name:find("/", 1, true) and "--full-path " or ""
  require("fzf-lua").files({
    cmd = fzf_lua_files_cmd .. full_path .. vim.fn.shellescape(utils.rg_escape(name)),
    prompt = (utils.ansi_from_hl("FzfLuaLivePrompt", name)) .. " > ", -- 語はfdの引数に埋め込むため、そのままでは画面に出ない
    cwd_prompt = false, -- filesは既定でpromptをcwd表示に上書きするため切る
  })
end

-- sm: ブックマーク(vim-bookmarks)の一覧。BookmarkShowAllでquickfixに書き出し、fzf-luaのquickfixで開く。
--   fzf-luaのquickfixの既定のctrl-x(list_del)は一覧から外すだけでブックマーク自体は消えないので、
--   ctrl-x/v/sはほかの一覧と同じ分割/タブに戻し、ブックマークの削除はctrl-d(選んだもの。tabで複数、ctrl-aで全部)で行う
local function bookmark_echo(msg, hl)
  vim.api.nvim_echo({ { msg, hl } }, false, {})
end

-- vim-bookmarksの自動保存は、バッファを離れるとき(BufLeave)に保存し、入るとき(BufEnter)に保存ファイルから読み直す。
-- fzfの窓を開いた時点で削除前の状態が保存され、閉じて戻ると読み直されて消したものが戻るため、消したらすぐ保存する
-- (保存先はBookmarkShowAll等と同じ。作業ディレクトリ/バッファごとに保存する設定は使っていない)
local function bookmark_save()
  if vim.g.bookmark_auto_save == 1 then
    vim.fn.BookmarkSave(vim.g.bookmark_auto_save_file, 1) -- 1: メッセージを出さない
  end
end

-- vim-bookmarksのs:bookmark_remove(スクリプトローカルで呼べない)と同じ手順で、1件消す
-- vim-bookmarksはブックマークを付けたときのパスで覚えている。~/gitは~/Documents/gitへのリンクで、同じファイルでも
-- 別のパスのバッファ(一覧の項目が指すバッファ)になることがあるため、実体のパスで比べて覚えているパスを探す
-- ファイルが無くなっている(名前の変更・削除)と実体のパスが求められないので、そのときは親のフォルダで求める
local function bookmark_realpath(file)
  local real = vim.uv.fs_realpath(file)
  if real then return real end
  local dir = vim.uv.fs_realpath(vim.fs.dirname(file))
  return dir and (dir .. "/" .. vim.fs.basename(file)) or file
end

local function bookmark_key(file)
  local real = bookmark_realpath(file)
  for _, key in ipairs(vim.fn["bm#all_files"]()) do
    if key == file or bookmark_realpath(key) == real then return key end
  end
end

local function bookmark_remove(file, lnum, bufnr)
  local key = bookmark_key(file)
  if key and vim.fn["bm#has_bookmark_at_line"](key, lnum) == 1 then
    local bm = vim.fn["bm#get_bookmark_by_line"](key, lnum)
    vim.fn["bm_sign#del"](key, bm.sign_idx)
    -- bm_sign#delはパスでサインを外すので、パスが違うバッファでは外れない。バッファ番号でも外す
    if bufnr then pcall(vim.fn.sign_unplace, "", { buffer = bufnr, id = bm.sign_idx }) end
    vim.fn["bm#del_bookmark_at_line"](key, lnum)
  end
end

local function bookmark_list()
  local fzf_lua = require("fzf-lua")
  vim.cmd("exec 'BookmarkShowAll' | cclose") -- 行番号をサインの位置に合わせ直してからquickfixに書き出す
  if #vim.fn.getqflist() == 0 then
    bookmark_echo("ブックマークはありません", "Normal")
    return
  end
  fzf_lua.quickfix({
    prompt = "BOOKMARKS> ",
    header = ":: " .. table.concat({
      fzf_hdr.bind("ctrl-d", "Delete"),
      fzf_hdr.hint("ctrl-a", "select all"),
      fzf_hdr.split_hint(),
    }, "|"),
    actions = {
      ["ctrl-x"] = fzf_lua.actions.file_split,
      ["ctrl-v"] = fzf_lua.actions.file_vsplit,
      ["ctrl-s"] = fzf_lua.actions.file_tabedit,
      -- 選んだブックマークを消して保存し、一覧を開き直す(全部消えたら閉じたまま)
      ["ctrl-d"] = function(selected, opts)
        for _, sel in ipairs(selected or {}) do
          local e = require("fzf-lua.path").entry_to_file(sel, opts)
          local file = e.bufnr and vim.api.nvim_buf_get_name(e.bufnr) or vim.fn.fnamemodify(e.path, ":p")
          if file ~= "" and e.line then bookmark_remove(file, e.line, e.bufnr) end
        end
        bookmark_save()
        vim.schedule(bookmark_list)
      end,
    },
  })
end

require('fzf-lua').setup{

    -- vim.ui.selectをfzfで表示する。LSPのcode_action(sda/ga)は変更内容の差分プレビュー付きになる。
    -- toggleterm/LuaSnip/mason/neogit等、vim.ui.selectを使う他プラグインの選択画面もfzfになる
    ui_select = {},

    -- パス表示を「ファイル名 ディレクトリ」の順にする(ディレクトリは薄色)。表示だけの変更で、
    -- ディレクトリ部分も絞り込み対象のまま。自作picker(ss/sw/sW/メモ)には効かない。
    -- お試し中。切り戻すときはこのdefaultsを削除する
    defaults = { formatter = "path.filename_first" },

    -- fzf本体(リスト・プロンプト・カーソル行・マッチ文字等)の配色をNeovimのハイライト
    -- (FzfLuaFzf*→Normal/CursorLine等)から取り、colorscheme(vscode.nvim)に合わせる。
    -- 切り戻すときはこの行を削除する(fzf既定の配色に戻る)
    fzf_colors = true,

    keymap = {
      -- 先頭のtrueで「デフォルトを継承して上書き」になる(無いと表ごと置き換えで、
      -- <M-Esc>(hide)やalt-g/alt-G(先頭/末尾)等のデフォルトが消える)。
      -- 継承したデフォルトを消すときは ["キー"] = false を指定する
      builtin = {
        true,
        -- neovim `:tmap` mappings for the fzf win
        ["<F1>"]        = "toggle-help",
        -- ["?"]        = "toggle-help",
        ["<F2>"]        = "toggle-fullscreen",
        -- Only valid with the 'builtin' previewer
        ["<F3>"]        = "toggle-preview-wrap",
        ["<F4>"]        = "toggle-preview",
        -- Rotate preview clockwise/counter-clockwise
        ["<F5>"]        = "toggle-preview-ccw",
        ["<F6>"]        = "toggle-preview-cw",
        ["<down>"]    = "preview-page-down",
        ["<up>"]      = "preview-page-up",
      },
      fzf = {
        true,
        -- fzf '--bind=' options
        ["ctrl-z"]      = "abort",
        ["ctrl-u"]      = "unix-line-discard",
        ["ctrl-f"]      = "half-page-down",
        ["ctrl-b"]      = "half-page-up",
        ["ctrl-a"]      = "toggle-all", -- ORG keymap
        -- ["ctrl-a"]      = "beginning-of-line",
        ["ctrl-e"]      = "end-of-line",
        -- ["alt-a"]       = "toggle-all",
        -- Only valid with fzf previewers (bat/cat/git/etc)
        ["f3"]          = "toggle-preview-wrap",
        ["f4"]          = "toggle-preview",
        ["shift-down"]  = "preview-page-down",
        ["shift-up"]    = "preview-page-up",
      },
    },
    actions = {
      files = {
        -- デフォルト継承でalt-i/alt-h/alt-f(ignore/hidden/followの切替)、alt-q/alt-Q(qf/loclistへ)、
        -- ctrl-t(タブで開く)が加わる。ctrl-tが不要なら ["ctrl-t"] = false で消せる
        true,
        ["default"] = actions.file_edit,
        ["ctrl-x"]  = actions.file_split,
        ["ctrl-v"]  = actions.file_vsplit,
        ["ctrl-s"]  = actions.file_tabedit,
        ["ctrl-q"]  = actions.file_sel_to_qf,
        ["ctrl-l"]  = actions.file_sel_to_ll, -- location listへ(fzf既定のclear-screenを上書き)
      },
      buffers = {
        true, -- 現状グローバルなbuffersのデフォルトは無いため実質変化なし(将来追加されたら継承する)
        ["default"] = actions.buf_edit,
        ["ctrl-v"]  = actions.buf_vsplit,
        ["ctrl-s"]  = actions.buf_tabedit,
        ["ctrl-q"]  = actions.buf_sel_to_qf,
        ["ctrl-l"]  = actions.buf_sel_to_ll, -- location listへ
      },
    },
    files = {
      rg_opts = "--color=never --files --hidden --follow -g '!.git'",
      fd_opts = "--color=never --type f --hidden --follow --exclude .git",
    },
    grep = {
      -- --hidden: sf(fd --hidden)と揃えて隠しファイル(.zshrc等)も検索する。.gitの中は除外
      -- --sortrは指定するとrgが並列処理をやめるため付けない(live grepで入力のたびに遅くなる)
      rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden -g '!.git' -e",
    },
    winopts = { height = 0.79, width = 0.90, row = 0.48, col = 0.45,
      preview = { hidden = false, vertical = "down:65%", layout = "vertical", },
    },
    fzf_opts = {
      -- fzfのデフォルトはファジー（曖昧）検索
      -- 純粋なgrepのように「入力した文字通りの部分一致」で厳密に絞り込みたい場合は、true
      ['--exact'] = true,
      -- 'index' は入力順（コマンド出力順）を維持します
      -- 'begin' や 'end' と組み合わせることで、ファイル名部分を優先的に評価させます
      ["--tiebreak"] = "index",
      -- --reverse(=--layout=reverse、プロンプトが上で候補が上から並ぶ)はfzf-luaの既定なので指定不要
    },

    -- cwdは指定しない(カレント基準)。以前は書きかけの "~/<folder>" が残っており、
    -- 実在しないためfzf-luaが毎回警告を出してcwdを捨てていた。挙動は当時と同じ
    vim.keymap.set({ "n" }, "sr", function() fzf_files_by_name(vim.fn.expand("<cword>")) end, { noremap = true, silent = true, desc = "Fzf file find cursor word" }),
    -- 選択した文字列でファイル名を検索
    vim.keymap.set({ "x" }, "sr", function()
      local sel = fzf_visual_text()
      if sel ~= "" then fzf_files_by_name(sel) end
    end, { noremap = true, silent = true, desc = "Fzf file find selection" }),
    -- カーソル下のファイル名(<cfile>。gfと同じ判定で init.lua や "init.lua" の中身を取る)で検索。
    -- lua/foo.lua のようなパスは末尾のファイル名だけを使う
    vim.keymap.set({ "n" }, "sR", function() fzf_files_by_name(vim.fn.fnamemodify(vim.fn.expand("<cfile>"), ":t")) end, { noremap = true, silent = true, desc = "Fzf file find cursor filename" }),

    vim.keymap.set({ "n" }, "sf", function() require("fzf-lua").files({
    }) end, { noremap = true, silent = true, desc = "Fzf file find" }),
    vim.keymap.set({ "n" }, "sgu", function() require("fzf-lua").grep_curbuf({
        search = "" .. require'fzf-lua.utils'.rg_escape(vim.fn.expand("<cword>")),
    }) end, { noremap = true, silent = true, desc = "Fzf grep file cursor word" }),
    -- 選択した文字列で今のファイルをgrep(sglの今のファイル版)。searchはgrep側でエスケープされる
    vim.keymap.set({ "x" }, "sgu", function()
      local sel = fzf_visual_text()
      if sel ~= "" then require("fzf-lua").grep_curbuf({ search = sel }) end
    end, { noremap = true, silent = true, desc = "Fzf grep file selection" }),

    -- x: 選択中の範囲で検索 / n: 前回選択した範囲('<,'>)で検索
    vim.keymap.set({ "n", "x" }, "sgl", function() require("fzf-lua").grep_visual({}) end, { noremap = true, silent = true, desc = "Fzf grep visual" }),
    -- 入力のたびにrgを再実行するlive grep。ctrl-gで「1回grepしてfzfで絞り込む」方式に切替
    vim.keymap.set({ "n" }, "sgg", function() require("fzf-lua").live_grep({}) end, { noremap = true, silent = true, desc = "Fzf live grep" }),
    vim.keymap.set({ "n" }, "sgr", function() require("fzf-lua").grep_cword({ prompt = fzf_word_prompt() }) end, { noremap = true, silent = true, desc = "Fzf grep cursor word"}),
    vim.keymap.set({ "n" }, "sgR", function() require("fzf-lua").grep_cWORD({ prompt = fzf_word_prompt("<cWORD>") }) end, { noremap = true, silent = true, desc = "Fzf grep cursor WORD" }),
    vim.keymap.set({ "n" }, "sgm", ":<C-u>GrugFar<CR>", { noremap = true, silent = true, desc = "GrugFar" }),

    vim.keymap.set({ "n" }, "sb", function() require("fzf-lua").buffers({}) end, { noremap = true, silent = true, desc = "Fzf buffers" }),
    -- x: 選択した行の範囲だけを対象にする(fzf-lua側がvisual modeを検出して範囲を絞る)
    vim.keymap.set({ "n", "x" }, "sl", function() require("fzf-lua").blines({}) end, { noremap = true, silent = true, desc = "Fzf current buffer line" }),
    vim.keymap.set({ "n" }, "sL", function() require("fzf-lua").lines({}) end, { noremap = true, silent = true, desc = "Fzf all buffer line" }),
    vim.keymap.set({ "n" }, "sh", function() require("fzf-lua").search_history({}) end, { noremap = true, silent = true, desc = "Fzf search history" }),
    vim.keymap.set({ "n" }, "sc", function() require("fzf-lua").changes({}) end, { noremap = true, silent = true, desc = "Fzf changes" }),
    vim.keymap.set({ "n" }, "sC", function() require("fzf-lua").command_history({}) end, { noremap = true, silent = true, desc = "Fzf command history" }),
    vim.keymap.set({ "n" }, "sz", function() require("fzf-lua").resume({}) end, { noremap = true, silent = true, desc = "Fzf resume" }),
    vim.keymap.set({ "n" }, "sj", function() require("fzf-lua").jumps({}) end, { noremap = true, silent = true, desc = "Fzf jumps" }),
    vim.keymap.set({ "n" }, "sk", function() require("fzf-lua").keymaps({}) end, { noremap = true, silent = true, desc = "Fzf keymaps" }),
    -- lsp
    -- conform.nvimでフォーマット(フォーマッタ未定義のファイルタイプはLSPのフォーマット)。visualなら選択範囲だけ
    vim.keymap.set({ "n", "x" }, "sdf", function() require("conform").format({ async = true }) end, { noremap = true, silent = true, desc = "format (conform)" }),
    -- 参照は1件でもジャンプせず一覧を出す(jump1=false)。他のsd*(定義等)は1件なら直接ジャンプのまま
    vim.keymap.set({ "n" }, "sdr", function() require("fzf-lua").lsp_references({ prompt = fzf_word_prompt(), jump1 = false }) end, { noremap = true, silent = true, desc = "Fzf lsp_references" }),
    vim.keymap.set({ "n" }, "sdd",function() require("fzf-lua").lsp_definitions({ prompt = fzf_word_prompt() }) end, { noremap = true, silent = true, desc = "Fzf lsp_definitions" }),
    vim.keymap.set({ "n" }, "sdD",function() require("fzf-lua").lsp_declarations({ prompt = fzf_word_prompt() }) end, { noremap = true, silent = true, desc = "Fzf lsp_declarations" }),
    -- 変数そのものの宣言ではなく、その変数の「型」の定義(interface/class等)へ飛ぶ
    vim.keymap.set({ "n" }, "sdt", function() require("fzf-lua").lsp_typedefs({ prompt = fzf_word_prompt() }) end, { noremap = true, silent = true, desc = "Fzf lsp_typedefs" }),
    vim.keymap.set({ "n" }, "sdi", function() require("fzf-lua").lsp_implementations({ prompt = fzf_word_prompt() }) end, { noremap = true, silent = true, desc = "Fzf lsp_implementations" }),
    vim.keymap.set({ "n" }, "sds", function() require("fzf-lua").lsp_document_symbols({}) end, { noremap = true, silent = true, desc = "lsp_document_symbols" }),
    -- VSCodeのCtrl+T相当。入力のたびにLSPへ問い合わせてプロジェクト全体のシンボル(定義)を探す。
    -- ctrl-gでlive検索⇔fzf絞り込みを切替。今のバッファに付いているLSPだけが対象
    vim.keymap.set({ "n" }, "sdS", function() require("fzf-lua").lsp_live_workspace_symbols({}) end, { noremap = true, silent = true, desc = "Fzf workspace symbols" }),
    -- 選択した文字列を検索語にして開く(開いた後も入力欄で編集できる)
    vim.keymap.set({ "x" }, "sdS", function() require("fzf-lua").lsp_live_workspace_symbols({ lsp_query = fzf_visual_text() }) end, { noremap = true, silent = true, desc = "Fzf workspace symbols (sel)" }),
    -- 診断の一覧。fzf-luaの既定は並べ替えなし(バッファ・診断の出どころ(LSP)ごとの順)なので、用途に合わせて並べる
    --   sdo: 今のバッファの診断を行番号順に全部(上から順に直す用)
    vim.keymap.set({ "n" }, "sdo", function()
      require("fzf-lua").diagnostics_document({
        ---@diagnostic disable-next-line: assign-type-mismatch
        sort = function(diags)
          table.sort(diags, function(a, b)
            if a.lnum ~= b.lnum then return a.lnum < b.lnum end
            return a.col < b.col
          end)
          return diags
        end,
      })
    end, { noremap = true, silent = true, desc = "Fzf diag buffer (by line)" }),
    --   sdO: 開いている全バッファ(jdtls等はプロジェクト全体)の診断を、エラー→警告の順で。
    --        件数が多くなるので、ヒント・情報は出さない
    vim.keymap.set({ "n" }, "sdO", function()
      require("fzf-lua").diagnostics_workspace({ sort = true, severity_limit = vim.diagnostic.severity.WARN })
    end, { noremap = true, silent = true, desc = "Fzf diag workspace (errors)" }),
    vim.keymap.set({ "n" }, "sdn", '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true, desc = "lsp rename" }),
    vim.keymap.set({ "n" }, "sda", '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true, desc = "lsp code_action" }),
    vim.keymap.set({ "n" }, "sde", '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true, desc = "lsp open_float" }),
    vim.keymap.set({ "n" }, "sd]", function() vim.diagnostic.jump({ count = 1 }) end, { noremap = true, silent = true, desc = "lsp goto_next" }),
    vim.keymap.set({ "n" }, "sd[", function() vim.diagnostic.jump({ count = -1 }) end, { noremap = true, silent = true, desc = "lsp goto_prev" }),
    -- org
    vim.keymap.set('n', 'ss', _G.fzf_mru, { noremap = true, silent = true, desc = "Fzf mru" }),
    vim.keymap.set('n', 'sw', function() _G.fzf_fav_file_list(false) end, { noremap = true, silent = true, desc = "Fzf fav file list" }),
    vim.keymap.set('n', 'sW', function() _G.fzf_fav_file_list(true) end, { noremap = true, silent = true, desc = "Fzf fav dir list" }),
    -- bookmark
    vim.keymap.set("n", "sm", bookmark_list, { noremap = true, silent = true, desc = "Fzf bookmarks" }),
    -- undo履歴(枝分かれも罫線のツリーで表示)。今の状態との差分をプレビューで見ながら選び、
    -- Enterでその状態に戻る(<F8>でプレビュー切替)
    vim.keymap.set("n", "su", function() require("fzf-lua").undotree() end, { noremap = true, silent = true, desc = "Fzf undotree" }),
}

-- --------------------------------------------------
-- Plugin:補完系
-- --------------------------------------------------

vim.diagnostic.config({
  -- エラー箇所に下線を引く(default: true)
  underline = true,
  -- 行末にエラーメッセージを表示(default: false)
  virtual_text = { source = "if_many" }, -- 複数のソース(ruff/pylsp/nvim-lint等)が診断を出しているときだけ、メッセージにソース名を付ける
  -- 行番号の横にアイコンを表示(default: true)。既定のE/W/I/Hの文字をnerd fontのアイコンに変える
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  -- 入力中は表示を更新しない(default: true)
  update_in_insert = false,
  -- 重大なエラーを優先表示(default: false)
  severity_sort = true,
  -- 診断のフロート(sde)でも、複数のソースがあるときだけソース名を付ける
  float = { source = "if_many" },
})

-- blink.cmp用の拡張capabilitiesを全LSPサーバーに渡す
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- hover/signature/診断などのフロート窓に一括で枠線を付ける(個別にborderを指定した窓はそちらが優先)
vim.o.winborder = "rounded"

-- カラーコード(#ff0000等)をその色で表示する(cssls等)。0.12では既定で有効だが明示しておく
vim.lsp.document_color.enable(true)
-- HTMLの開始タグを編集すると閉じタグも同時に変わる(対応サーバーのみ)
vim.lsp.linked_editing_range.enable(true)

-- keyboard shortcut: LSPが実際にアタッチしたバッファにのみ設定する
-- LSP操作はsd*系(Plugin:fzf-lua)に寄せているので、ここではKだけ。
-- (以前はg*系にも割り当てていたが、gf/gt/gi/gn/ga等のVim標準の動作や、
--  0.11以降の標準のgrr/grn/gra等を潰していたため削除した)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = args.buf, silent = true })

    if client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    -- 折りたたみをLSPのfoldingRangeにする(import・コメント・メソッド等、treesitterより意味の単位に近い)。
    -- 詳細はlsp_or_ts_foldexprの説明を参照
    if client:supports_method('textDocument/foldingRange') then
      for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
        vim.wo[win][0].foldmethod = "expr"
        vim.wo[win][0].foldexpr = "v:lua.lsp_or_ts_foldexpr()"
      end
    end
  end,
})

-- LSPの応答が届くまではtreesitter、届いた後はLSPの折りたたみを返すfoldexpr。
-- LSPは応答が届くまで折りたたみが無く(lua_lsで5〜10秒)、foldcolumn=auto:6の列が一度消えて文字がずれるため。
-- 切り替えはこの関数の中で行い、'foldexpr'の値は変えない
-- (LSP側は'foldexpr'が変わるとLSPの折りたたみを止めて作り直し、また応答待ちになる)。
-- LSPの結果に折りたたみが1つでも出たら準備完了とし、折りたたみを計算し直して、importの塊を閉じる(バッファごとに1回)。
-- vim.lsp.foldexpr()は、LSPの折りたたみが有効になる前は呼ぶたびに「有効にする処理」を予約する。
-- 1行ごとに呼ぶと4000行のファイルで8000回を超えて積まれ、起動直後の色付きの描画が遅れるので、
-- バッファごとに最初の1回だけ呼んで予約させ、有効になるまでは呼ばない
do
  local lsp_fold = {} -- bufnr -> "kicked"(有効にする処理を予約した) / "on"(有効になった) / "ready"(LSPの結果が届いた)
  function _G.lsp_or_ts_foldexpr()
    local bufnr = vim.api.nvim_get_current_buf()
    local st = lsp_fold[bufnr]
    if st == "ready" then
      return vim.lsp.foldexpr(vim.v.lnum)
    end
    if st == nil then
      lsp_fold[bufnr] = "kicked"
      vim.lsp.foldexpr(vim.v.lnum)
      -- 予約された「有効にする処理」の後に走る(vim.scheduleは順番どおり)
      vim.schedule(function()
        if lsp_fold[bufnr] == "kicked" then lsp_fold[bufnr] = "on" end
      end)
    elseif st == "on" and vim.lsp.foldexpr(vim.v.lnum) ~= "0" then
      lsp_fold[bufnr] = "ready"
      -- foldexprの中ではfoldmethodの変更等ができないので後に回す
      vim.schedule(function()
        for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
          if vim.wo[win].foldexpr == "v:lua.lsp_or_ts_foldexpr()" then
            vim.wo[win][0].foldmethod = "expr" -- 設定し直すと折りたたみが計算し直される
            vim.lsp.foldclose("imports", win)
          end
        end
      end)
    end
    return vim.treesitter.foldexpr()
  end
end

-- 次/前のメソッド名の先頭へ移動する(<M-j>/<M-k>)。countも使える(3<M-j>で3つ先)。
-- LSPのdocumentSymbol(sdsと同じ情報)からメソッド/コンストラクタ/関数の名前の位置(selectionRange)を集めて移動する。
-- Vim標準の]m/[mは{の位置に止まり、ラムダ等の{にも止まるため。LSPが無いバッファでは]m/[mで代用する
local method_symbol_kinds = { [6] = true, [9] = true, [12] = true } -- Method, Constructor, Function
local function goto_method(dir)
  local bufnr = vim.api.nvim_get_current_buf()
  local count = vim.v.count1
  local client = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/documentSymbol" })[1]
  if not client then
    vim.cmd("normal! " .. count .. (dir > 0 and "]m" or "[m"))
    return
  end
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  client:request("textDocument/documentSymbol", params, function(err, result)
    -- 応答が来るまでに別のバッファへ移っていたら何もしない
    if err or not result or vim.api.nvim_get_current_buf() ~= bufnr then
      return
    end
    local positions = {}
    local function collect(symbols)
      for _, s in ipairs(symbols) do
        if method_symbol_kinds[s.kind] then
          -- DocumentSymbolならselectionRange(名前)、SymbolInformationならlocation.range(宣言全体)の先頭
          local pos = (s.selectionRange or s.location.range).start
          local line = vim.api.nvim_buf_get_lines(bufnr, pos.line, pos.line + 1, false)[1] or ""
          table.insert(positions, { pos.line + 1, vim.str_byteindex(line, client.offset_encoding, pos.character, false) })
        end
        if s.children then
          collect(s.children) -- 内部クラスのメソッド等
        end
      end
    end
    collect(result)
    table.sort(positions, function(a, b) return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2]) end)

    local cur = vim.api.nvim_win_get_cursor(0)
    local target, n = nil, 0
    local first, last, step = 1, #positions, 1
    if dir < 0 then
      first, last, step = #positions, 1, -1
    end
    for i = first, last, step do
      local p = positions[i]
      local ahead = p[1] > cur[1] or (p[1] == cur[1] and p[2] > cur[2])
      local behind = p[1] < cur[1] or (p[1] == cur[1] and p[2] < cur[2])
      if (dir > 0 and ahead) or (dir < 0 and behind) then
        target, n = p, n + 1
        if n == count then
          break
        end
      end
    end
    if target then
      vim.api.nvim_win_set_cursor(0, target)
    end
  end, bufnr)
end
vim.keymap.set("n", "<M-j>", function() goto_method(1) end, { noremap = true, silent = true, desc = "next method name" })
vim.keymap.set("n", "<M-k>", function() goto_method(-1) end, { noremap = true, silent = true, desc = "prev method name" })

-- 3. completion (saghen/blink.cmp)
require('blink.cmp').setup({
  keymap = {
    preset = 'none', -- 既存キーを維持しつつblink標準キーも追加するため個別定義
    -- 既存キー（挙動を維持）
    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-l>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'hide', 'fallback' },
    ['<CR>']  = { 'accept', 'fallback' },
    -- blink標準キー（新規追加。標準プリセットと同じ挙動）
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-y>']     = { 'select_and_accept' },
    ['<Tab>']     = { 'snippet_forward', 'fallback' },
    ['<S-Tab>']   = { 'snippet_backward', 'fallback' },
    -- ドキュメント窓のスクロール。blinkのkeymapは挿入モードだけで、ドキュメント窓が出ていないときは
    -- fallbackで本来のキーに戻るので、ノーマルモードのページ移動(<C-f>/<C-b>)とはぶつからない
    ['<C-f>']     = { 'scroll_documentation_down', 'fallback' },
    ['<C-b>']     = { 'scroll_documentation_up', 'fallback' },
    -- シグネチャ(引数ヒント)の表示切替
    ['<C-k>']     = { 'show_signature', 'hide_signature', 'fallback' },
  },
  completion = {
    -- 先頭候補を自動では選択しない。<C-n>/<C-p>で選ぶと本文に仮に入り(auto_insert)、
    -- 選んでいないときの<CR>はただの改行になる。先頭候補をそのまま確定するなら<C-y>
    list = { selection = { preselect = false, auto_insert = true } },
    -- 旧experimental.ghost_text相当。未選択でも先頭候補をゴーストテキストで見せる(<C-y>で入る内容)
    ghost_text = { enabled = true, show_without_selection = true },
    menu = {
      border = 'rounded',
      draw = {
        -- アイコン / ラベル(colorful-menuで型シグネチャ等も色付き) / 候補の出どころ(LSP・Buffer等)
        columns = { { 'kind_icon' }, { 'label', gap = 1 }, { 'source_name' } },
        components = {
          label = {
            text = function(ctx) return require('colorful-menu').blink_components_text(ctx) end,
            highlight = function(ctx) return require('colorful-menu').blink_components_highlight(ctx) end,
          },
        },
      },
    },
    -- 候補を選ぶとドキュメントを自動で横に出す(<C-l>/<C-space>で手動の表示切替も可)
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      window = { border = 'rounded' },
    },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    -- luaではlazydev(vim.*やプラグインのAPI)も候補に出す
    per_filetype = {
      lua = { inherit_defaults = true, 'lazydev' },
    },
    providers = {
      lazydev = {
        name = 'LazyDev',
        module = 'lazydev.integrations.blink',
        score_offset = 100, -- lua_lsより上に出す
      },
      path = {
        opts = {
          -- blinkの既定は隠しファイル非表示(cmp-pathは'.'入力で出ていた)。
          -- ドットファイルを扱うことが多いので常に候補に含める
          show_hidden_files_by_default = true,
        },
      },
    },
  },
  snippets = { preset = 'luasnip' }, -- LuaSnipのexpand/jumpを自動連携
  signature = { enabled = true, window = { border = 'rounded' } }, -- 入力中に関数シグネチャ(引数ヒント)をポップアップ表示
})

-- blink.cmpが補完ウィンドウの描画・completeoptを内部で制御するため、
-- 旧cmp向けのvim.opt.completeopt明示設定は不要

-- LUA manual
--   https://github.com/L3MON4D3/LuaSnip
-- LUA sample
--   https://github.com/honza/vim-snippets/tree/master/snippets

require("luasnip.loaders.from_snipmate").lazy_load({paths = "~/.config/nvim/luasnippets/"})
-- luasnippets/*.lua（ファイル名=filetype、all.luaは全filetype）を読み込む。保存すると自動で読み直される
require("luasnip.loaders.from_lua").lazy_load({ paths = "~/.config/nvim/luasnippets/" })

-- friendly-snippets（VSCode形式のスニペット集）をLuaSnipに読み込ませる
require("luasnip.loaders.from_vscode").lazy_load()

-- --------------------------------------------------
-- Plugin:lua
-- --------------------------------------------------

-- init.lua で vim変数が未定義になるのでその対応

vim.lsp.config("lua_ls", {
     settings = {
         Lua = {
             diagnostics = {
                  globals = { "vim" }
             }
         }
     }
})


-- --------------------------------------------------
-- Plugin:conform
-- --------------------------------------------------
-- フォーマットはsdf(visualなら選択範囲)。保存時の自動フォーマットはしない
require("conform").setup({
  formatters_by_ft = {
    python = { "ruff_format" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    sh = { "shfmt" },
  },
  -- 上にないファイルタイプ(lua/java/sql等)はLSPのフォーマットを使う
  default_format_opts = { lsp_format = "fallback" },
})

-- --------------------------------------------------
-- Plugin:java
-- --------------------------------------------------
-- jdtlsはnvim-jdtlsで起動する(mason-lspconfigの自動起動からは外している)

-- 起動したディレクトリ(グローバルのcwd)をjdtlsのルートにできるか。
-- prjroot/{A,B,C}/pom.xmlのような構成でprjrootで起動したとき、ファイルから一番近いpom.xml(A)を
-- ルートにするとAしか取り込まれずBのクラスが見えないため、cwdをルートにして全部取り込ませる。
-- ホーム等で起動したときに丸ごと読み込まないよう、ファイルがcwdの下にあり、かつcwd自身か
-- その直下のディレクトリにビルドファイルがあるときだけ使う
local jdtls_build_files = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts" }

-- ルート直下の.jdtls-foldersに書いたフォルダも、同じjdtlsに取り込ませる(LSPのworkspace folders)。
-- ルートの外にある別のプロジェクト(../projectHomeDirB/F等)に依存しているとき、
-- mvn installしなくてもソースのまま参照できるようにするため。書き方:
--   1行に1つフォルダのパス。相対パスは.jdtls-foldersからの相対。~/や絶対パスも可。
--   行頭が#の行と空行は無視(パスに#を含められるよう、行の途中の#はコメント扱いしない)
local function jdtls_extra_folders(root)
  local conf = root .. "/.jdtls-folders"
  if not vim.uv.fs_stat(conf) then
    return {}
  end
  local folders = {}
  for _, line in ipairs(vim.fn.readfile(conf)) do
    line = vim.trim(line)
    if line ~= "" and not vim.startswith(line, "#") then
      local path = vim.fs.normalize(line) -- ~/を展開
      if not vim.startswith(path, "/") then
        path = vim.fs.normalize(root .. "/" .. path) -- ../を解決
      end
      if vim.uv.fs_stat(path) then
        table.insert(folders, vim.fn.resolve(path))
      else
        vim.notify(".jdtls-folders: 見つかりません: " .. line, vim.log.levels.WARN)
      end
    end
  end
  return folders
end

local function jdtls_cwd_root(file)
  local cwd = vim.fn.resolve(vim.fn.getcwd(-1, -1)) -- lcdの影響を受けない、起動時(:cd)のcwd
  local has_build_file = false
  for _, name in ipairs(jdtls_build_files) do
    if vim.uv.fs_stat(cwd .. "/" .. name) or vim.fn.glob(cwd .. "/*/" .. name) ~= "" then
      has_build_file = true
      break
    end
  end
  if not has_build_file then
    return nil
  end
  if vim.startswith(file, cwd .. "/") then
    return cwd
  end
  -- .jdtls-foldersで追加したフォルダのファイル(定義ジャンプでF側を開いた等)も、
  -- 別のjdtlsを立ち上げずにcwdをルートにしたjdtlsへつなぐ
  for _, folder in ipairs(jdtls_extra_folders(cwd)) do
    if vim.startswith(file, folder .. "/") then
      return cwd
    end
  end
  return nil
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  group = vim.api.nvim_create_augroup("nvim_jdtls", { clear = true }),
  callback = function(args)
    local file = vim.fn.resolve(vim.api.nvim_buf_get_name(args.buf))
    local root = jdtls_cwd_root(file)
      or vim.fs.root(args.buf, { "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
      or vim.fs.dirname(file)
    local folders = { root, unpack(jdtls_extra_folders(root)) }
    -- プロジェクトごとにjdtlsのworkspace(インデックス等)を分ける
    local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(root, ":p:h"):gsub("/", "_")
    require("jdtls").start_or_attach({
      cmd = { vim.fn.stdpath("data") .. "/mason/bin/jdtls", "-data", workspace },
      root_dir = root,
      -- ルートと.jdtls-foldersのフォルダをまとめてjdtlsに渡す。
      -- jdtlsはLSP標準のworkspaceFoldersではなく、init_options.workspaceFoldersのURIからプロジェクトを取り込む
      workspace_folders = vim.tbl_map(function(dir)
        return { uri = vim.uri_from_fname(dir), name = vim.fs.basename(dir) }
      end, folders),
      init_options = {
        workspaceFolders = vim.tbl_map(vim.uri_from_fname, folders),
      },
      -- vim.lsp.startで起動するのでvim.lsp.config('*')は効かない。blink.cmpのcapabilitiesを直接渡す
      capabilities = require("blink.cmp").get_lsp_capabilities(),
      settings = {
        java = {
          -- workspace/symbolは既定だと型(クラス等)しか返さず、sdSでメソッドを探せないため
          symbols = { includeSourceMethodDeclarations = true },
        },
      },
    })
  end,
})

-- --------------------------------------------------
-- Plugin:vim-quickhl
-- --------------------------------------------------
vim.keymap.set('n', 'cm', '<Plug>(quickhl-manual-this)', { noremap = true, silent = true })
vim.keymap.set('x', 'cm', '<Plug>(quickhl-manual-this)', { noremap = true, silent = true })
vim.keymap.set('n', 'cj', '<Plug>(quickhl-cword-toggle)', { noremap = true, silent = true })

-- --------------------------------------------------
-- Plugin:quickrun
-- --------------------------------------------------
vim.keymap.set('n', '<Leader>r', ':<C-u>QuickRun<CR>', { noremap = true, silent = true, desc = "QuickRun" })

-- --------------------------------------------------
-- memo
--   memolist.vimは2022-11以降更新が止まっているため、:MemoNew相当だけを
--   自前で持つ。一覧(g,m)と検索(g,s)は従来どおりfzf-lua側が担当する
-- --------------------------------------------------
local memo_dir = vim.fn.expand("~/git/memolist")

-- memolist.vimのesctitle相当。小文字化し、空白/スラッシュ/引用符を-に潰す。
-- 日本語はそのまま残るので既存メモ(2022-02-19-どうソートされるかな.txt等)と
-- 同じ命名規則になる
local function memo_slug(title)
  local s = title:lower()
  s = s:gsub("[ /\\'\"]", "-")
  s = s:gsub("%-%-+", "-")
  s = s:gsub("^%-+", ""):gsub("%-+$", "")
  return s
end

local function memo_new()
  local title = vim.fn.input("Memo title: ")
  if title == "" then
    return
  end

  local path = memo_dir .. "/" .. os.date("%Y-%m-%d-") .. memo_slug(title) .. ".md"
  local is_new = vim.fn.filereadable(path) == 0

  vim.fn.mkdir(memo_dir, "p")
  -- 編集中の内容を失わないよう、変更ありなら分割して開く(memolist.vimと同じ挙動)
  vim.cmd((vim.bo.modified and "split " or "edit ") .. vim.fn.fnameescape(path))

  if is_new then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "# " .. title,
      "",
      "- date: " .. os.date("%Y-%m-%d"),
      "",
      "---",
      "",
      "",
    })
    vim.api.nvim_win_set_cursor(0, { 7, 0 }) -- 本文の書き始め位置へ
  end
end

vim.api.nvim_create_user_command("MemoNew", memo_new, { desc = "新しいメモを作成" })
vim.keymap.set("n", "g,c", memo_new, { noremap = true, silent = true, desc = "memo new" })

-- 一覧の並び順。true=更新日時順(ls -t) / false=作成日順(ファイル名の降順 ls -r)
local memo_sort_mtime = true


local function memo_header()
  -- ctrl-oのラベルは「押すとどうなるか」を示す(fzf-lua既定の流儀に合わせる)
  return ":: " .. table.concat({
    fzf_hdr.bind("ctrl-o", memo_sort_mtime and "Sort by created" or "Sort by modified"),
    fzf_hdr.bind("ctrl-r", "Rename"),
    fzf_hdr.bind("ctrl-d", "Delete"),
    fzf_hdr.split_hint(),
  }, "|") .. ", sort: " .. require("fzf-lua.utils")
    .ansi_from_hl("FzfLuaHeaderText", memo_sort_mtime and "modified" or "created")
end

-- メモ一覧。以前はls|sedをfzf_execへ直接流していたが、その経路では
-- file_icons/color_icons が効かない(fn_transformを通さないと適用されない)ため
-- files()に変更した。アイコン・プレビュー・パス解決が標準経路になる。
-- ここで指定したactionsはグローバルのactions.filesとマージされるので、
-- default/ctrl-x/ctrl-v/ctrl-s/ctrl-q は従来どおり効く
-- メモ一覧。ディレクトリを自分で読んで並べ替え、サイズ/更新日時/作成日時の
-- カラム付きで表示する。以前は files() に ls を渡していたが、カラムを
-- 付けるには表示文字列を自前で組む必要があるためfzf_execに変更した。
-- 選択値から実パスへは_fmt.fromで戻すので、fzf-lua標準のアクション
-- (enter/ctrl-x/v/s/q)もそのまま効く。
local function memo_entries()
  local list = {}
  local fs = vim.uv.fs_scandir(memo_dir)
  while fs do
    local name, t = vim.uv.fs_scandir_next(fs)
    if not name then
      break
    end
    if t == "file" then
      local path = memo_dir .. "/" .. name
      list[#list + 1] = { name = name, path = path, stat = vim.uv.fs_stat(path) }
    end
  end
  table.sort(list, function(a, b)
    if memo_sort_mtime then
      local sa = a.stat and a.stat.mtime.sec or 0
      local sb = b.stat and b.stat.mtime.sec or 0
      if sa ~= sb then
        return sa > sb
      end
    end
    -- 作成日順はファイル名(YYYY-MM-DD-)の降順で代用する
    return a.name > b.name
  end)
  return list
end

local memo_list
memo_list = function()
  local fzf_lua = require("fzf-lua")
  local utils = require("fzf-lua.utils")
  local dev = require("nvim-web-devicons")
  local list = memo_entries()

  -- 表示上は先頭の "YYYY-MM-DD-" を落とし、日付はcreatedカラムへ回す。
  -- ファイル自体は変更しない(e.nameは実ファイル名のまま保持)。
  -- birthtimeはコピーや移動で書き換わり実際の作成日と合わないことがあるため
  -- (47件中16件が不一致)、こちらの日付の方が信用できる
  for _, e in ipairs(list) do
    e.date = e.name:match("^(%d%d%d%d%-%d%d%-%d%d)%-") or "-"
    e.title = e.name:gsub("^%d%d%d%d%-%d%d%-%d%d%-", "")
  end

  local name_w = 0
  for _, e in ipairs(list) do
    name_w = math.max(name_w, vim.fn.strdisplaywidth(e.title) + 2)
  end
  name_w = math.min(name_w, 70)

  local by_display = {}
  local items = {}
  for _, e in ipairs(list) do
    local icon, hl = dev.get_icon(e.name, vim.fn.fnamemodify(e.name, ":e"), { default = true })
    local name = utils.ansi_from_hl(hl, icon or "") .. " " .. e.title
    local d = fzf_cols.row(name, utils.strip_ansi_coloring(name), name_w, e.stat, e.date)
    by_display[utils.strip_ansi_coloring(d)] = e
    items[#items + 1] = d
  end

  local function picked(selected)
    return selected and selected[1] and by_display[utils.strip_ansi_coloring(selected[1])]
  end

  fzf_lua.fzf_exec(items, {
    prompt = "MEMO> ",
    header = memo_header() .. "\n" .. fzf_cols.header(name_w, "created"),
    previewer = "builtin",
    _fmt = {
      from = function(entry)
        local e = by_display[utils.strip_ansi_coloring(entry)]
        return e and e.path or entry
      end,
    },
    -- 名前から日付を外したので、createdカラム(3列目)も検索対象に含める。
    -- これで "2026-09" のような日付での絞り込みが従来どおり効く
    fzf_opts = vim.tbl_extend("force", { ["--no-sort"] = "" }, fzf_cols.fzf_opts("1,3")),
    actions = {
      -- fzf_execはグローバルのactions.filesを引き継がないため明示する。
      -- いずれもentry_to_file経由なので_fmt.fromで実パスに解決される
      ["default"] = fzf_lua.actions.file_edit,
      ["ctrl-x"]  = fzf_lua.actions.file_split,
      ["ctrl-v"]  = fzf_lua.actions.file_vsplit,
      ["ctrl-s"]  = fzf_lua.actions.file_tabedit,
      ["ctrl-q"]  = fzf_lua.actions.file_sel_to_qf,
      ["ctrl-l"]  = fzf_lua.actions.file_sel_to_ll, -- location listへ
      -- 作成日順 <-> 更新日順 の切り替え。開き直して反映する
      ["ctrl-o"] = function()
        memo_sort_mtime = not memo_sort_mtime
        vim.schedule(memo_list)
      end,
      ["ctrl-r"] = function(selected)
        local e = picked(selected)
        if not e then
          return
        end
        local new = vim.fn.input("Rename: ", e.name)
        if new ~= "" and new ~= e.name then
          local ok, err = vim.uv.fs_rename(e.path, memo_dir .. "/" .. new)
          if not ok then
            vim.notify("リネーム失敗: " .. tostring(err), vim.log.levels.ERROR)
          end
        end
        vim.schedule(memo_list)
      end,
      ["ctrl-d"] = function(selected)
        local e = picked(selected)
        if not e then
          return
        end
        -- 取り消せない操作なので既定をNoにして確認する
        if vim.fn.confirm("削除しますか？\n" .. e.name, "&No\n&Yes", 1) == 2 then
          local ok, err = vim.uv.fs_unlink(e.path)
          if not ok then
            vim.notify("削除失敗: " .. tostring(err), vim.log.levels.ERROR)
          end
        end
        vim.schedule(memo_list)
      end,
    },
  })
end

vim.keymap.set("n", "g,m", memo_list, { noremap = true, silent = true, desc = "memo list" })
vim.keymap.set({ "n" }, "g,s", function() require("fzf-lua").live_grep(vim.tbl_extend("force", {
  cwd = "~/git/memolist/",
  winopts = { height = 0.79, width = 0.90, row = 0.48, col = 0.45,
    preview = { hidden = false, vertical = "down:65%", layout = "vertical", },
  },
}, fzf_hdr.after_cwd_opts())) end, { noremap = true, silent = true, desc = "memo grep" })

-- --------------------------------------------------
-- Plugin:nvim-treesitter
-- --------------------------------------------------
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
local langs = { "lua", "vim", "query", "javascript", "html", "bash", "java", "json", "css", "yaml", "python", "typescript", "csv", "markdown", "xml", "zsh", "sql" }
require("nvim-treesitter").install(langs)

-- ハイライトの有効化。Neovimが標準でtreesitterを使うのはLua/Markdown/Vim script等の一部だけで、
-- それ以外(Java/Python/TS/HTML等)はパーサーを入れても古い構文ハイライト(syntax)のままになるため、
-- パーサーがあるFileTypeでは明示的に開始する。
-- treesitterのハイライトは解析を描画と並行して(非同期で)行うため、開いた直後の数コマは色が付かないまま描かれる
-- (init.luaで約0.1秒)。最初の解析だけ同期で済ませて、最初の画面から色を付ける。巨大なファイルは固まるので非同期のまま
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if lang and vim.treesitter.language.add(lang) and pcall(vim.treesitter.start, args.buf, lang)
      and vim.api.nvim_buf_line_count(args.buf) <= 20000 then
      local parser = vim.treesitter.get_parser(args.buf, lang, { error = false })
      if parser then parser:parse() end
    end
  end,
})

-- FileTypeごとの既定のインデント(全体の既定はスペース4)。新規・空のファイル用で、
-- 中身のあるファイルはguess-indent.nvimが実際のインデントに合わせ直し、.editorconfigがあればそれが優先される
local indent_by_ft = {
  -- スペース2が慣習の言語
  [2] = { "lua", "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc",
          "yaml", "html", "css", "scss", "vue", "markdown" },
}
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("indent_by_filetype", { clear = true }),
  callback = function(args)
    for width, fts in pairs(indent_by_ft) do
      if vim.tbl_contains(fts, args.match) then
        vim.bo[args.buf].shiftwidth = width
        vim.bo[args.buf].tabstop = width
        vim.bo[args.buf].softtabstop = width
        vim.bo[args.buf].expandtab = true
      end
    end
    -- Go(gofmt)とMakefileはタブ必須
    if args.match == "go" or args.match == "make" then
      vim.bo[args.buf].expandtab = false
    end
  end,
})


-- --------------------------------------------------
-- Plugin:nvim-treesitter-textobjects
-- --------------------------------------------------
-- 関数・クラス・引数を単位にした選択。visualとオペレータ待ち(d/c/y等の後)で使う。
--   af/if: 関数全体/関数の中身   例) daf=関数ごと削除  cif=関数の中身を書き換え
--   ac/ic: クラス全体/クラスの中身
--   aa/ia: 引数(区切りのカンマ込み)/引数だけ   例) daa=引数を1つ削除
-- lookahead: カーソルが対象の外にあっても、行の先にある次の対象を選ぶ(targets.vimと同様)
require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
    selection_modes = {
      ["@function.outer"] = "V", -- 関数全体は行単位で選ぶ
      ["@class.outer"] = "V",
    },
  },
})
for key, query in pairs({
  af = "@function.outer", ["if"] = "@function.inner",
  ac = "@class.outer", ic = "@class.inner",
  aa = "@parameter.outer", ia = "@parameter.inner",
}) do
  vim.keymap.set({ "x", "o" }, key, function()
    require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
  end, { desc = "textobject " .. query })
end

-- --------------------------------------------------
-- コメント設定
-- --------------------------------------------------
vim.keymap.set("n", "<C-/><C-/>", "gcc", { remap = true })
vim.keymap.set("v", "<C-/><C-/>", "gc", { remap = true })

vim.keymap.set("n", "<C-_><C-_>", "gcc", { remap = true })
vim.keymap.set("v", "<C-_><C-_>", "gc", { remap = true })

-- --------------------------------------------------
-- Plugin:toggleterm
-- --------------------------------------------------
require("toggleterm").setup{
  size = 25,
}

local toggleterm_augroup = vim.api.nvim_create_augroup("user_toggleterm", { clear = true })
vim.api.nvim_create_autocmd("TermEnter", {
  group = toggleterm_augroup,
  pattern = "term://*toggleterm#*",
  callback = function(args)
    vim.keymap.set("t", "<C-\\>", "<Cmd>exe v:count1 . 'ToggleTerm size=25'<CR>",
      { buffer = args.buf, silent = true })
    vim.keymap.set("t", "<C-¥>", "<Cmd>exe v:count1 . 'ToggleTerm size=25'<CR>",
      { buffer = args.buf, silent = true })
  end,
})

vim.keymap.set("n", "<C-\\>", "<Cmd>exe v:count1 . 'ToggleTerm name=default'<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-\\>", "<Esc><Cmd>exe v:count1 . 'ToggleTerm name=default'<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-¥>", "<Cmd>exe v:count1 . 'ToggleTerm name=default'<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-¥>", "<Esc><Cmd>exe v:count1 . 'ToggleTerm name=default'<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<Leader>t", ":<C-u>TermNew<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>T", ":<C-u>TermNew direction=tab<CR>", { noremap = true, silent = true })
vim.keymap.set("v", "<Leader>c", ":<C-u>ToggleTermSendVisualSelection<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>c", ":<C-u>ToggleTermSendCurrentLine<CR>", { noremap = true, silent = true })

vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", { noremap = true, silent = true })

-- --------------------------------------------------
-- undoの永続化
--   undofileで保存時にundo履歴を~/.local/state/nvim/undo/へ書き出し、次に開いたときも戻せるようにする。
--   ただしuを連打して前回以前の状態まで戻ってしまわないよう、開いた時点を境界にして
--     u: 今回開いてからの変更だけを戻す。境界に来たら止めて、Uを案内する
--     U: 境界より前(ファイルに保存されていた履歴)だけを戻す。uで戻せる変更が残っていればエラー
--   に分ける。<C-r>(redo)は普通に動く。g-/:undo N/:earlier/su(fzf-luaのundotree)はこの制御を通らない
-- --------------------------------------------------
vim.opt.undofile = true

-- undoの番号(seq)がこれ以下の変更は、ファイルから読み込んだ履歴。
-- 開いた時点(BufReadPost)のseq_lastを記録する。:e!や外部変更の自動読み込みで読み直したときも更新する
local function undo_boundary(buf)
  return vim.b[buf].undo_boundary or 0
end

-- seqの変更がされた日時(undotreeのentriesを枝も含めて探す)
local function undo_change_time(seq)
  local function find(entries)
    for _, e in ipairs(entries) do
      if e.seq == seq then
        return e.time
      end
      if e.alt then
        local t = find(e.alt)
        if t then return t end
      end
    end
  end
  local t = find(vim.fn.undotree().entries)
  return t and os.date("%Y-%m-%d %H:%M", t) or "?"
end

local function undo_count(entries)
  local n = 0
  for _, e in ipairs(entries) do
    n = n + 1 + (e.alt and undo_count(e.alt) or 0)
  end
  return n
end

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("persistent_undo", { clear = true }),
  callback = function(args)
    local tree = vim.fn.undotree(args.buf)
    vim.b[args.buf].undo_boundary = tree.seq_last
    vim.b[args.buf].undo_loaded_seq = tree.seq_cur -- 開いた時点(ディスクと同じ内容)の位置
    -- 履歴があることを、そのバッファで最初に開いたときだけ知らせる
    if tree.seq_last > 0 and not vim.b[args.buf].undo_notified then
      vim.b[args.buf].undo_notified = true
      local n = undo_count(tree.entries)
      vim.schedule(function()
        vim.api.nvim_echo({ { ("このファイルには undo の履歴が %d 件あります(U で戻せます)"):format(n), "Comment" } }, false, {})
      end)
    end
  end,
})

-- 保存すればディスクと同じ内容になるので、その位置を「開いた時点」とみなす(ファイル履歴の表示も消える)
vim.api.nvim_create_autocmd("BufWritePost", {
  group = "persistent_undo",
  callback = function(args)
    vim.api.nvim_buf_call(args.buf, function() vim.b[args.buf].undo_loaded_seq = vim.fn.changenr() end)
  end,
})

-- u: 今回の変更だけを戻す。countは境界の手前で止める
vim.keymap.set("n", "u", function()
  local buf = vim.api.nvim_get_current_buf()
  local boundary = undo_boundary(buf)
  for _ = 1, vim.v.count1 do
    local nr = vim.fn.changenr() -- 次にundoで取り消す変更の番号
    if nr > boundary then
      vim.cmd("silent undo")
    elseif nr > 0 then
      vim.api.nvim_echo({ { ("ここから先は前回以前の履歴です（%s の変更）。U でファイル履歴から戻せます"):format(undo_change_time(nr)), "WarningMsg" } }, false, {})
      return
    else
      vim.api.nvim_echo({ { "Already at oldest change", "Normal" } }, false, {})
      return
    end
  end
  vim.api.nvim_echo({ { ("undo: #%d"):format(vim.fn.changenr()), "Normal" } }, false, {})
end, { noremap = true, silent = true, desc = "undo (今回の変更だけ)" })

-- U: ファイルに保存されていた履歴を戻す(Vim標準の行undoの代わり)
vim.keymap.set("n", "U", function()
  local buf = vim.api.nvim_get_current_buf()
  local boundary = undo_boundary(buf)
  if vim.fn.changenr() > boundary then
    vim.api.nvim_echo({ { "u で戻せる変更(今回の変更)が残っています。先に u で戻してください", "ErrorMsg" } }, false, {})
    return
  end
  local last
  for _ = 1, vim.v.count1 do
    local nr = vim.fn.changenr()
    if nr == 0 then
      break
    end
    last = nr
    vim.cmd("silent undo")
  end
  if not last then
    vim.api.nvim_echo({ { "ファイル履歴はありません", "Normal" } }, false, {})
    return
  end
  vim.api.nvim_echo({ { ("ファイル履歴: %s の変更を戻しました（<C-r> でやり直し）"):format(undo_change_time(last)), "WarningMsg" } }, false, {})
end, { noremap = true, silent = true, desc = "undo (ファイル履歴)" })

-- 今の状態までに適用されている変更の番号(undoの木で、今の位置の祖先)。
-- undotree().entriesは今の枝の変更の列で、altはその位置から分かれた別の枝(その要素の代わりに適用される)
local function undo_applied_seqs(entries, target, applied)
  for _, e in ipairs(entries) do
    if e.seq == target then
      applied[e.seq] = true
      return true
    end
    if e.alt then
      local sub = vim.deepcopy(applied)
      if undo_applied_seqs(e.alt, target, sub) then
        for k in pairs(sub) do applied[k] = true end
        return true
      end
    end
    applied[e.seq] = true
  end
  return false
end

-- ステータスライン用。開いた時点(または最後に保存した時点)の状態を含まない状態、
-- つまりUやg-等でそれより前の履歴に戻っている間に表示する(保存するとディスクを古い内容で上書きする)。
-- <C-r>で開いた時点まで戻れば消える。開いてからの変更だけなら出ない
function _G.undo_history_status()
  local loaded = vim.b.undo_loaded_seq
  if not loaded or loaded == 0 then
    return ""
  end
  local cur = vim.fn.changenr()
  if cur == loaded then
    return ""
  end
  local applied = {}
  if cur > 0 then
    undo_applied_seqs(vim.fn.undotree().entries, cur, applied)
  end
  return applied[loaded] and "" or "[ファイル履歴を表示中]"
end

-- --------------------------------------------------
-- Plugin:lualine
-- --------------------------------------------------
require("lualine").setup{
  options = {
    icons_enabled = true,
    -- 'auto'だと配色名(vscode)に対応するvscode.nvim同梱のテーマ(青基調)が選ばれる。
    -- 移行前に'auto'が読んでいたlualine同梱のcodedarkテーマを固定して、ステータスラインの色を元に揃える
    theme = 'codedark',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filesize', 'filename'},
    lualine_x = {
      -- Uでファイル履歴(開く前の状態)に戻っている間だけ表示(undoの永続化を参照)
      { _G.undo_history_status, color = "WarningMsg" },
      'encoding', 'fileformat', 'filetype',
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},          -- 空のまま。winbarはdropbar.nvimが使うのでlualineでは持たない
  inactive_winbar = {},
  extensions = {}
}

-- --------------------------------------------------
-- keymap
-- --------------------------------------------------
-- sキーのバインドを消す
vim.keymap.set("", "s", "")

-- 拡張正規表現をデフォルトにする
vim.keymap.set("n", "/", "/\\v", { noremap = true })

-- xはヤンクしないでブラックホールレジスタへ
vim.keymap.set("n", "x", '"_x', { noremap = true })
vim.keymap.set("v", "x", '"_x', { noremap = true })
vim.keymap.set("x", "x", '"_x', { noremap = true })

-- ウィンドウ関係
--   <C-w>*/# でウィンドウ分割して検索 http://goo.gl/wAQHM
vim.keymap.set("n", "<C-w>*", "<C-w>s*", { noremap = true })
vim.keymap.set("n", "<C-w>#", "<C-w>s#", { noremap = true })

vim.keymap.set("n", "<C-w>N", ":vnew<CR>", { noremap = true })

-- Quickfix系
vim.keymap.set("n", "<Leader>qq", ":<C-u>copen<CR>", { noremap = true, silent = true, desc = "quickfix open" })
vim.keymap.set("n", "<Leader>qi", ":<C-u>cgetbuffer|cwindow<CR>", { noremap = true, silent = true, desc = "quickfix buffer insert" })
vim.keymap.set("n", "<Leader>qo", ":<C-u>QFToBuf<CR>", { noremap = true, silent = true, desc = "quickfix -> new tab" })
-- fzf版(<Leader>l*と対称)。f:項目を絞り込む h:以前のリスト(履歴)から選ぶ g:含まれるファイル全体をlive grep
vim.keymap.set("n", "<Leader>qf", function() require("fzf-lua").quickfix({}) end, { noremap = true, silent = true, desc = "Fzf quickfix" })
vim.keymap.set("n", "<Leader>qh", function() require("fzf-lua").quickfix_stack({}) end, { noremap = true, silent = true, desc = "Fzf quickfix history" })
vim.keymap.set("n", "<Leader>qg", function() require("fzf-lua").lgrep_quickfix({}) end, { noremap = true, silent = true, desc = "Fzf grep in quickfix files" })
-- 最後の検索(/や*)の一致を今のバッファから集めてquickfixに書き出し、開く(hlslens)。
-- qfreplaceで一括置換するときはこちら。grepの結果を上書きしたくなければ<Leader>ls
vim.keymap.set("n", "<Leader>qs", function()
  if require("hlslens").exportLastSearchToQuickfix(false) then
    vim.cmd("copen")
    vim.opt_local.number = true -- 何行目の一致か分かるよう、この窓だけ行番号を出す(quickerの既定はOFF)
  else
    vim.notify("検索の一致をquickfixに書き出せませんでした(検索していない等)", vim.log.levels.WARN)
  end
end, { noremap = true, silent = true, desc = "search matches -> quickfix" })

-- Locationlist系
vim.keymap.set("n", "<Leader>ll", ":<C-u>lopen<CR>", { noremap = true, silent = true, desc = "locationlist open" })
vim.keymap.set("n", "<Leader>li", ":<C-u>lgetbuffer|lwindow<CR>", { noremap = true, silent = true, desc = "locationlist buffer insert" })
vim.keymap.set("n", "<Leader>lo", ":<C-u>LocToBuf<CR>", { noremap = true, silent = true, desc = "locationlist -> new tab" })
-- fzf版(<Leader>q*と対称)。location listは窓ごとなので、そのリストを持つ窓で実行する
vim.keymap.set("n", "<Leader>lf", function() require("fzf-lua").loclist({}) end, { noremap = true, silent = true, desc = "Fzf locationlist" })
vim.keymap.set("n", "<Leader>lh", function() require("fzf-lua").loclist_stack({}) end, { noremap = true, silent = true, desc = "Fzf locationlist history" })
vim.keymap.set("n", "<Leader>lg", function() require("fzf-lua").lgrep_loclist({}) end, { noremap = true, silent = true, desc = "Fzf grep in loclist files" })
-- 最後の検索(/や*)の一致を今のバッファから集めてlocation listに書き出し、開く(hlslens)。
-- location listは窓ごとなので、quickfix(grepの結果等)を上書きしない
vim.keymap.set("n", "<Leader>ls", function()
  if require("hlslens").exportLastSearchToQuickfix(true) then
    vim.cmd("lopen")
    vim.opt_local.number = true -- 何行目の一致か分かるよう、この窓だけ行番号を出す(quickerの既定はOFF)
  else
    vim.notify("検索の一致をlocation listに書き出せませんでした(検索していない等)", vim.log.levels.WARN)
  end
end, { noremap = true, silent = true, desc = "search matches -> locationlist" })

-- タブ関係
--   c-w tで新しくタブを開く
vim.keymap.set("n", "<C-w>t", ":tabnew<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-w>c", ":bd!<CR>", { noremap = true, silent = true })

--   バッファの切替
vim.keymap.set("n", "<M-n>", ":bn<CR>", { noremap = true, silent = true, desc = "next buffer" })
vim.keymap.set("n", "<M-p>", ":bp<CR>", { noremap = true, silent = true, desc = "prev buffer" })

--   次/前のタブ
vim.keymap.set("n", "<C-n>", "gt", { noremap = true, silent = true })
vim.keymap.set("n", "<C-p>", "gT", { noremap = true, silent = true })

-- タグジャンプ
vim.keymap.set("n", "t1", ":<C-u>tabnext1<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "t2", ":<C-u>tabnext2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "t3", ":<C-u>tabnext3<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "t4", ":<C-u>tabnext4<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "t5", ":<C-u>tabnext5<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "t6", ":<C-u>tabnext6<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "t7", ":<C-u>tabnext7<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "t8", ":<C-u>tabnext8<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "t9", ":<C-u>tabnext9<CR>", { noremap = true, silent = true })

--   カレントタブ以外は閉じる
vim.keymap.set("n", "to", ":tabonly<CR>", { noremap = true, silent = true })

-- Visual コピー時にカーソル位置を保存
vim.keymap.set("x", "y", "mzy`z", { noremap = true, silent = true })
-- Visual ペースト時にレジスタの変更を防止
vim.keymap.set("x", "p", "P", { noremap = true, silent = true })

-- --------------------------------------------------
-- keymap:org
-- --------------------------------------------------

-- 簡易メモを開く
vim.keymap.set("n", "g,u", ":<C-u>split ~/git/conf/memo.txt<CR>", { noremap = true, silent = true, desc = "open memo.txt" })

-- 無名バッファを一時ファイルにしちゃう
vim.keymap.set("n", ",z", ":<C-u>MumeiBuffer<CR>", { noremap = true, silent = true, desc = "buffer temp save" })
vim.cmd([[
command! MumeiBuffer if expand('%:t') ==# '' | file `=tempname()` | w | endif
]])

-- ファイルフォーマット指定
vim.keymap.set("n", ",ft", ":<C-u>set ft=", { noremap = true })
vim.keymap.set("n", ",st", ":<C-u>set syntax=", { noremap = true })

-- j, k による移動を折り返されたテキストでも自然に振る舞うように変更
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })

vim.keymap.set("n", "gj", "j", { noremap = true })
vim.keymap.set("n", "gk", "k", { noremap = true })

-- vを二回で行末まで選択
vim.keymap.set("v", "v", "$h", { noremap = true })

-- 連続貼付け用
vim.keymap.set("v", "<C-p>", "0p", { noremap = true, silent = true })

-- ,,系(トグル・,,f*のコピー等)の結果の表示。メッセージが複数行になったり画面幅を超えたり、
-- 2つ続けて出たりすると「Press ENTER or type command to continue」で止まるため、常に1行に収めて出す。
-- chunksは{ { 文字列, ハイライト }, ... }。fit=trueの要素は、全体が1行に収まるよう…で切り詰める
local function line_msg(chunks)
  local width = vim.v.echospace - 1 -- 右端のruler/showcmdの分を除いた、1行に表示できる幅
  local fixed = 0
  for _, c in ipairs(chunks) do
    c[1] = c[1]:gsub("%s*\n%s*", " ⏎ ")
    if not c.fit then fixed = fixed + vim.fn.strdisplaywidth(c[1]) end
  end
  for _, c in ipairs(chunks) do
    local room = width - fixed
    if c.fit and vim.fn.strdisplaywidth(c[1]) > room then
      local out = ""
      for _, ch in ipairs(vim.fn.split(c[1], "\\zs")) do
        if vim.fn.strdisplaywidth(out .. ch) > room - 1 then break end
        out = out .. ch
      end
      c[1] = out .. "…"
    end
  end
  vim.api.nvim_echo(vim.tbl_map(function(c) return { c[1], c[2] } end, chunks), true, {})
end

-- トグルの結果を「<日本語名>(<オプション名>): ON/OFF  [<影響範囲>]」で出す。
-- valueがbooleanならON(緑)/OFF(灰)、文字列ならその値(2つの値を行き来するもの)
local function toggle_text(value)
  if type(value) == "boolean" then
    return value and "ON" or "OFF", value and "DiagnosticOk" or "Comment"
  end
  return value, "DiagnosticOk"
end
local function toggle_msg(label, value, scope)
  local text, hl = toggle_text(value)
  line_msg({ { label .. ": ", "Normal" }, { text, hl }, { "  [" .. scope .. "]", "Comment" } })
end

-- フォーカス表示: twilight.nvimのように、カーソルのある範囲の外を暗くする。範囲は「入れ子の段」から選び、1段ずつ狭めたり広げたりできる。
--   段: カーソルを含むものを外から順に並べる。LSP(documentSymbol)のクラス・メソッド等 → その内側のtreesitterの
--       関数・if・for・{}等(nvim-treesitter-textobjectsのquery)。LSPが無いバッファはtreesitterだけで作る
--   ,,z: ON/OFF(togglesの一覧表。ONにしたときはメソッドの段から始める)
--   <Leader>-: 1段狭める <Leader>+: 1段広げる(countも使える) <Leader>.: カーソルのある一番内側の段にする
--   カーソルを動かすと、同じ段の深さのまま範囲を作り直す。0段目はファイル全体(何も暗くしない)
-- ,,zの項目から使う関数だけfocus_dimに出し、残りはdo ... endの中に閉じる
local focus_dim = {}
do
  local ns = vim.api.nvim_create_namespace("focus_dim")
  -- 段にするLSPの記号: Module, Namespace, Class, Method, Constructor, Enum, Interface, Function, Struct
  local container_kinds = { [2] = true, [3] = true, [5] = true, [6] = true, [9] = true, [10] = true, [11] = true, [12] = true, [23] = true }
  local ts_captures = { ["class.outer"] = true, ["function.outer"] = true, ["conditional.outer"] = true, ["loop.outer"] = true, ["block.outer"] = true }
  local state = { enabled = false, level = 0 } -- init_pending: 始めの段(メソッド)をまだ決めていない。pending_delta: その間に押された分
  local symbols = {}    -- bufnr -> { tick = changedtick, list = { { s, e, name, kind }, ... } } (行は0始まり、両端を含む)
  local requesting = {} -- bufnr -> true(documentSymbolの応答待ち)
  local last = {}       -- 前回暗くした範囲(同じなら描き直さない)
  local augroup = vim.api.nvim_create_augroup("focus_dim", { clear = true })

  -- 色は明示し、colorschemeの読み直しでも付け直す(背景は透明なので文字色だけ)
  local function focus_hl()
    vim.api.nvim_set_hl(0, "FocusDim", { fg = "#5a5a5a" })
  end
  focus_hl()
  vim.api.nvim_create_autocmd("ColorScheme", { group = vim.api.nvim_create_augroup("focus_dim_hl", { clear = true }), callback = focus_hl })

  local function lsp_client(bufnr)
    return vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/documentSymbol" })[1]
  end

  local update

  local function request_symbols(bufnr, client)
    if requesting[bufnr] then return end
    requesting[bufnr] = true
    local tick = vim.b[bufnr].changedtick
    local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
    client:request("textDocument/documentSymbol", params, function(err, result)
      requesting[bufnr] = nil
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
      local list = {}
      local function collect(syms)
        for _, s in ipairs(syms) do
          if container_kinds[s.kind] then
            -- DocumentSymbolならrange(宣言全体)、SymbolInformationならlocation.range。終わりが行頭なら前の行まで
            local r = s.range or s.location.range
            local e = r["end"].character == 0 and r["end"].line - 1 or r["end"].line
            table.insert(list, { r.start.line, e, s.name, s.kind })
          end
          if s.children then collect(s.children) end
        end
      end
      if not err and result then collect(result) end
      -- 失敗しても空の一覧を入れる(treesitterだけで段を作り、始めの段も決められるように)
      symbols[bufnr] = { tick = tick, list = list }
      if state.enabled and vim.api.nvim_get_current_buf() == bufnr then update(true) end
    end, bufnr)
  end

  -- カーソル行rowを含む段を外から順に返す。{ s, e, label, method }(methodはメソッド・関数の段)
  local function chain(bufnr, row, client)
    local items, seen = {}, {}
    local function add(s, e, label, method)
      local key = s .. ":" .. e
      if e > s and s <= row and row <= e and not seen[key] then -- 1行だけのものは段にしない。同じ行範囲はLSPを優先
        seen[key] = true
        table.insert(items, { s = s, e = e, label = label, method = method })
      end
    end
    local sym = client and symbols[bufnr]
    local inner -- LSPの記号のうち一番内側のもの。treesitterの段はこの内側だけ使う
    if sym then
      for _, s in ipairs(sym.list) do
        add(s[1], s[2], s[3], s[4] == 6 or s[4] == 9 or s[4] == 12)
      end
      for _, it in ipairs(items) do
        if not inner or it.e - it.s < inner.e - inner.s then inner = it end
      end
    end
    local parser = vim.treesitter.get_parser(bufnr, nil, { error = false })
    local query = parser and vim.treesitter.query.get(parser:lang(), "textobjects")
    local tree = parser and query and parser:parse()[1]
    if query and tree then
      local root = tree:root()
      for id, node in query:iter_captures(root, bufnr, row, row + 1) do
        local name = query.captures[id]
        if ts_captures[name] then
          local s, _, e, ec = node:range()
          if ec == 0 and e > s then e = e - 1 end
          if not inner or (s >= inner.s and e <= inner.e) then
            local label = vim.trim(vim.api.nvim_buf_get_lines(bufnr, s, s + 1, false)[1] or "")
            add(s, e, label, name == "function.outer")
          end
        end
      end
    end
    -- 外から順(始まりが前、同じなら終わりが後ろのもの)に並べ、入れ子になっていないものは除く
    table.sort(items, function(a, b) return a.s < b.s or (a.s == b.s and a.e > b.e) end)
    local out = {}
    for _, it in ipairs(items) do
      local prev = out[#out]
      if not prev or (it.s >= prev.s and it.e <= prev.e) then table.insert(out, it) end
    end
    return out
  end

  local function show(lv, items)
    local item = items[lv]
    line_msg({ { ("フォーカス %d/%d"):format(lv, #items), "Normal" }, { item and ": " .. item.label or ": ファイル全体", "Comment", fit = true } })
  end

  local function clamp_level(delta, items)
    state.level = math.max(0, math.min(math.min(state.level, #items) + delta, #items))
  end

  update = function(force, notify)
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].buftype ~= "" then return end -- 通常のファイルだけ
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local tick = vim.b[bufnr].changedtick
    local client = lsp_client(bufnr)
    if client and (not symbols[bufnr] or symbols[bufnr].tick ~= tick) and not vim.fn.mode():match("^i") then
      request_symbols(bufnr, client) -- 入力中は取り直さない(InsertLeaveで取り直す)
    end
    local items = chain(bufnr, row, client)
    if state.init_pending and (not client or symbols[bufnr]) then
      -- 始めの段は、外から最初のメソッド・関数の段。無ければ一番外の段
      state.level = #items > 0 and 1 or 0
      for i, it in ipairs(items) do
        if it.method then state.level = i break end
      end
      state.init_pending = false
      clamp_level(state.pending_delta or 0, items)
      state.pending_delta = nil
      notify = true
    end
    local lv = math.min(state.level, #items)
    local item = items[lv]
    local key = item and (item.s .. ":" .. item.e) or ""
    if force or last.buf ~= bufnr or last.key ~= key or last.tick ~= tick then
      last = { buf = bufnr, key = key, tick = tick }
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      if item then
        local opts = { hl_group = "FocusDim", hl_eol = true, priority = 10000, strict = false }
        if item.s > 0 then
          vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, vim.tbl_extend("force", opts, { end_row = item.s, end_col = 0 }))
        end
        local n = vim.api.nvim_buf_line_count(bufnr)
        if item.e + 1 < n then
          vim.api.nvim_buf_set_extmark(bufnr, ns, item.e + 1, 0, vim.tbl_extend("force", opts, { end_row = n, end_col = 0 }))
        end
      end
    end
    if notify and not state.init_pending then show(lv, items) end
  end

  local function enable()
    state.enabled, state.level, state.init_pending, state.pending_delta = true, 0, true, nil
    last = {}
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter", "TextChanged", "InsertLeave" }, {
      group = augroup,
      callback = function() update(false) end,
    })
    -- 段の表示は、,,zのトグルの表示(ON)の後に出す
    vim.schedule(function()
      if state.enabled then update(true) end
    end)
  end

  local function disable()
    state.enabled = false
    vim.api.nvim_clear_autocmds({ group = augroup })
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_clear_namespace(b, ns, 0, -1)
    end
  end

  -- 1段狭める(delta>0)/広げる(delta<0)。OFFなら先にONにする。始めの段が決まる前(LSPの応答待ち)なら、決まってから反映する
  local function shift(delta)
    if not state.enabled then enable() end
    if state.init_pending then
      state.pending_delta = (state.pending_delta or 0) + delta
      return
    end
    local bufnr = vim.api.nvim_get_current_buf()
    clamp_level(delta, chain(bufnr, vim.api.nvim_win_get_cursor(0)[1] - 1, lsp_client(bufnr)))
    update(true, true)
  end

  -- カーソルのある一番内側の段にする。OFFなら先にONにする
  local function innermost()
    if not state.enabled then enable() end
    if state.init_pending then
      state.pending_delta = math.huge -- 始めの段が決まってから、一番内側まで狭める
      return
    end
    local bufnr = vim.api.nvim_get_current_buf()
    state.level = #chain(bufnr, vim.api.nvim_win_get_cursor(0)[1] - 1, lsp_client(bufnr)) -- その深さに固定する
    update(true, true)
  end

  function focus_dim.enabled() return state.enabled end
  function focus_dim.toggle()
    if state.enabled then disable() else enable() end
    return state.enabled
  end

  vim.keymap.set("n", "<Leader>-", function() shift(vim.v.count1) end, { noremap = true, silent = true, desc = "focus narrow" })
  vim.keymap.set("n", "<Leader>+", function() shift(-vim.v.count1) end, { noremap = true, silent = true, desc = "focus widen" })
  vim.keymap.set("n", "<Leader>.", innermost, { noremap = true, silent = true, desc = "focus innermost" })
end

-- ,,系のトグルの一覧。キーの割り当て・,,?(fzfで状態を見て切り替え)・which-keyの説明(今の状態を出す)をここから作る。
--   get(): 今の値(booleanか、表示用の文字列)。toggle(): 切り替えて、切り替え後の値を返す。
--   どちらも「今のウィンドウ/バッファ」に対して動く(,,?からはfzfを開く前の窓でnvim_win_callする)
local function local_opt(name)
  return {
    get = function() return vim.wo[name] end,
    toggle = function()
      vim.opt_local[name] = not vim.wo[name] -- 今のウィンドウだけ(:setlocal)
      return vim.wo[name]
    end,
  }
end
local toggles = {
  -- フォーカス表示(カーソルのあるメソッド・ブロックの外を暗くする)。詳細はfocus_dimの説明を参照
  { key = ",,z", label = "フォーカス表示(focus)", scope = "全体",
    get = focus_dim.enabled, toggle = focus_dim.toggle },
  -- 分割ファイルのスクロールを同期。今のウィンドウの状態を反転した値に、タブ内の全ウィンドウをそろえる
  -- (各ウィンドウをそれぞれ反転すると、ON/OFFが混ざっていたときに同期がそろわないため。
  --  windoはカーソルが最後のウィンドウに移ってしまうので使わない)。フロート窓は対象外
  { key = ",,s", label = "スクロール同期(scrollbind)", scope = "全ウィンドウ",
    get = function() return vim.wo.scrollbind end,
    toggle = function()
      local on = not vim.wo.scrollbind
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.fn.win_gettype(win) == "" then vim.wo[win][0].scrollbind = on end
      end
      return on
    end },
  vim.tbl_extend("error", { key = ",,n", label = "行番号(number)", scope = "ウィンドウ" }, local_opt("number")),
  vim.tbl_extend("error", { key = ",,r", label = "相対行番号(relativenumber)", scope = "ウィンドウ" }, local_opt("relativenumber")),
  vim.tbl_extend("error", { key = ",,w", label = "折り返し(wrap)", scope = "ウィンドウ" }, local_opt("wrap")),
  -- wrap時のインデント
  vim.tbl_extend("error", { key = ",,b", label = "折返しインデント(breakindent)", scope = "ウィンドウ" }, local_opt("breakindent")),
  -- タブ・行末の空白等を見えるようにする(listcharsの記号で表示)
  vim.tbl_extend("error", { key = ",,l", label = "空白の可視化(list)", scope = "ウィンドウ" }, local_opt("list")),
  -- カーソル行の強調(カーソルを見失ったとき用)
  vim.tbl_extend("error", { key = ",,c", label = "カーソル行の強調(cursorline)", scope = "ウィンドウ" }, local_opt("cursorline")),
  -- virtualedit（たまに行末超えのペーストしたいので）。block(矩形選択のみ) ⇔ all(どこでも)
  { key = ",,v", label = "仮想編集(virtualedit)", scope = "ウィンドウ",
    get = function()
      local v = vim.wo.virtualedit
      return v == "all" and "all（どこでも）" or v == "block" and "block（矩形選択のみ）" or (v == "" and "なし" or v)
    end,
    toggle = function()
      vim.opt_local.virtualedit = vim.wo.virtualedit ~= "all" and "all" or "block"
      return vim.wo.virtualedit == "all" and "all（どこでも）" or "block（矩形選択のみ）"
    end },
  -- 記号を隠す表示(Markdownのリンク記法やJSONの引用符等)。0(すべて表示) ⇔ 2(隠す)
  { key = ",,t", label = "記号を隠す(conceallevel)", scope = "ウィンドウ",
    get = function() return vim.wo.conceallevel == 0 and "0（すべて表示）" or (vim.wo.conceallevel .. "（隠す）") end,
    toggle = function()
      vim.opt_local.conceallevel = vim.wo.conceallevel == 0 and 2 or 0
      return vim.wo.conceallevel == 0 and "0（すべて表示）" or "2（隠す）"
    end },
  -- LSPのインレイヒント(引数名・型のヒント)。既定はON(LspAttachで有効化)
  { key = ",,h", label = "インレイヒント(inlay_hint)", scope = "バッファ",
    get = function() return vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }) end,
    toggle = function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
      return vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
    end },
  -- 診断(行末のメッセージ・下線・サイン)の表示をまとめて。コードだけ読みたいとき用
  { key = ",,d", label = "診断の表示(diagnostic)", scope = "バッファ",
    get = function() return vim.diagnostic.is_enabled({ bufnr = 0 }) end,
    toggle = function()
      vim.diagnostic.enable(not vim.diagnostic.is_enabled({ bufnr = 0 }), { bufnr = 0 })
      return vim.diagnostic.is_enabled({ bufnr = 0 })
    end },
  -- diffで空白の差分(インデントの付け外し・行末空白・行中の空白の有無など。git diff -w相当)を無視するか。
  -- diffoptはグローバルなので、DiffOrg/DiffToggle/Diffview/gitsignsのサインすべてに効く
  { key = ",,i", label = "diffの空白の無視(iwhiteall)", scope = "全体",
    get = function() return vim.tbl_contains(vim.opt.diffopt:get(), "iwhiteall") end,
    toggle = function()
      if vim.tbl_contains(vim.opt.diffopt:get(), "iwhiteall") then
        vim.opt.diffopt:remove("iwhiteall")
      else
        vim.opt.diffopt:append("iwhiteall")
      end
      return vim.tbl_contains(vim.opt.diffopt:get(), "iwhiteall")
    end },
  -- ペーストモード(pasteはグローバルのみのオプション)
  { key = ",,p", label = "ペーストモード(paste)", scope = "全体",
    get = function() return vim.o.paste end,
    toggle = function()
      vim.o.paste = not vim.o.paste
      return vim.o.paste
    end },
}
for _, t in ipairs(toggles) do
  vim.keymap.set("n", t.key, function() toggle_msg(t.label, t.toggle(), t.scope) end,
    { noremap = true, silent = true, desc = t.label })
end

-- which-keyで,,を押したときの一覧に、各トグルの今の状態を出す(「折り返し(wrap): OFF」)。
-- descを関数にすると、which-keyは表示のたびに評価する
pcall(function()
  require("which-key").add(vim.tbl_map(function(t)
    return { t.key, desc = function() return t.label .. ": " .. (toggle_text(t.get())) end }
  end, toggles))
end)

-- ,,?: トグルの一覧をfzfで出し、今の状態を見ながらenterで切り替える。
-- 切り替えてもfzfは閉じず、一覧を読み直して新しい状態を出す(続けて複数切り替えられる)。
-- fzfの窓ではなく、fzfを開く前のウィンドウ/バッファに対して切り替える
vim.keymap.set("n", ",,?", function()
  local utils = require("fzf-lua.utils")
  local win = vim.api.nvim_get_current_win()
  local lw = 0
  for _, t in ipairs(toggles) do lw = math.max(lw, vim.fn.strdisplaywidth(t.label)) end
  local by_key = {}
  for _, t in ipairs(toggles) do by_key[t.key] = t end

  local function contents(cb)
    for _, t in ipairs(toggles) do
      local text, hl = toggle_text(vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_call(win, t.get) or t.get())
      cb(("%s  %s%s  %s"):format(t.key, fzf_cols.pad(t.label, lw + 2),
        utils.ansi_from_hl(hl, fzf_cols.pad(text, 22)), utils.ansi_from_hl("Comment", t.scope)))
    end
    cb(nil)
  end

  require("fzf-lua").fzf_exec(contents, {
    prompt = "TOGGLE> ",
    header = ":: " .. fzf_hdr.bind("enter", "toggle") .. ", " .. fzf_hdr.hint("esc", "close"),
    previewer = false,
    winopts = { height = #toggles + 4, width = 0.60, row = 0.40, preview = { hidden = true } },
    -- 読み直しても、選んでいた行(キー)にカーソルを残す
    fzf_opts = { ["--no-sort"] = "", ["--id-nth"] = "1", ["--track"] = "" },
    actions = {
      ["default"] = {
        fn = function(selected)
          local key = selected and selected[1] and utils.strip_ansi_coloring(selected[1]):match("^(%S+)")
          local t = key and by_key[key]
          if t and vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_call(win, t.toggle) end
        end,
        reload = true,
      },
    },
  })
end, { noremap = true, silent = true, desc = "toggles (fzf)" })

-- 検索ハイライトオフ（ctrl+lに機能をプラス）。Neovim本来の<C-l>(nohlsearch|diffupdate|normal! <C-L>)に
-- QuickhlManualResetを足したもの(QuickhlManualResetは後ろに|でコマンドをつなげられないので最後に置く)。
-- 最後の画面の再描画で、メッセージ欄に残った検索語(/pattern)や件数([3/4])も消す
vim.keymap.set("n", "<C-l>", ":<C-u>nohlsearch | diffupdate | QuickhlManualReset<CR><Cmd>normal! <C-l><CR>", { noremap = true, silent = true, desc = "nohlsearch + redraw" })

-- WSLではvim.ui.open(gxや,,fo等)がxdg-open(Linux側のブラウザを探す)を優先してしまい、
-- WindowsのブラウザでURLが開かないため、Windowsの既定のアプリ(wslviewが無ければexplorer.exe)で開く
if vim.fn.has("wsl") == 1 then
  local open = vim.ui.open
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.ui.open = function(path, opt)
    opt = opt or {}
    if not opt.cmd then
      opt.cmd = vim.fn.executable("wslview") == 1 and { "wslview" } or { "explorer.exe" }
    end
    return open(path, opt)
  end
end

-- ,,f*の結果の表示(line_msgで1行に収める)。
--   成功: 「<何を>をコピー: <内容>」。途中の警告(まだpushされていない等)はcopy_warnでためておき、
--         内容の後ろに「  (<警告>)」で付けて全体を黄色にする。内容が長ければ内容の方を切り詰める
--   失敗: 「<何を>をコピー: <理由>」を赤で
local copy_warns = {}
local function copy_warn(msg)
  table.insert(copy_warns, msg)
end
local function copy_done(label, content)
  local hl = #copy_warns > 0 and "WarningMsg" or "Normal"
  local chunks = { { label .. ": ", hl }, { content, hl, fit = true } }
  if #copy_warns > 0 then
    table.insert(chunks, { "  (" .. table.concat(copy_warns, " / ") .. ")", hl })
  end
  copy_warns = {}
  line_msg(chunks)
end
local function copy_fail(label, reason)
  copy_warns = {}
  line_msg({ { label .. ": " .. reason, "ErrorMsg", fit = true } })
end

-- クリップボード(+レジスタ)にコピーして内容を表示する。+はclipboard providerを通るのでMac/WSLどちらでも動く
local function copy_to_clipboard(label, text)
  vim.fn.setreg("+", text)
  copy_done(label, text)
end

-- 対象の行範囲。visualなら選択範囲(visualは抜ける)、ノーマルならカーソル行
local function current_line_range()
  local l1, l2 = vim.fn.line("."), vim.fn.line(".")
  if vim.fn.mode():match("^[vV\22]") then
    l1 = vim.fn.line("v")
    if l1 > l2 then l1, l2 = l2, l1 end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  end
  return l1, l2
end

-- ファイルのパス/名前をコピーする。with_lineなら「:10」「:10-12」を付ける
local function copy_file_path(modifier, with_line, label)
  local text = vim.fn.expand("%" .. modifier)
  if vim.fn.expand("%:p") == "" then
    current_line_range() -- visualは抜けておく
    copy_fail(label, "ファイルではありません")
    return
  end
  if with_line then
    local l1, l2 = current_line_range()
    text = text .. ":" .. l1 .. (l2 ~= l1 and ("-" .. l2) or "")
  else
    current_line_range()
  end
  copy_to_clipboard(label, text)
end
local copy_opts = { noremap = true, silent = true }
-- フルパス / フルパス:行番号
vim.keymap.set({ "n", "x" }, ",,fp", function() copy_file_path(":p", false, "フルパスをコピー") end, vim.tbl_extend("force", copy_opts, { desc = "full path clipboard copy" }))
vim.keymap.set({ "n", "x" }, ",,fP", function() copy_file_path(":p", true, "フルパス:行をコピー") end, vim.tbl_extend("force", copy_opts, { desc = "full path:line clipboard copy" }))
-- ファイル名 / ファイル名:行番号
vim.keymap.set({ "n", "x" }, ",,ff", function() copy_file_path(":t", false, "ファイル名をコピー") end, vim.tbl_extend("force", copy_opts, { desc = "file name clipboard copy" }))
vim.keymap.set({ "n", "x" }, ",,fF", function() copy_file_path(":t", true, "ファイル名:行をコピー") end, vim.tbl_extend("force", copy_opts, { desc = "file name:line clipboard copy" }))

-- 今のファイルのGitHubのURL(+行番号)をクリップボードにコピー。visualでは選択範囲の行(#L10-L20)を付ける。
-- ドメイン/リポジトリはoriginのURLから組み立てる。
--   ,,fg: ブランチ名のURL(/blob/master/...)。常に最新版を指すが、後でファイルが変わると行番号がずれる
--   ,,fG: コミットSHAで固定したパーマリンク(/blob/<sha>/...)。後から見ても同じ内容を指す
local function git_out(dir, args)
  local r = vim.system(vim.list_extend({ "git", "-C", dir }, args), { text = true }):wait()
  return r.code == 0 and vim.trim(r.stdout) or nil
end

local function remote_to_https(url)
  url = url:gsub("/$", ""):gsub("%.git$", "")
  local host, path = url:match("^[%w_.-]+@([^:/]+):(.+)$") -- git@github.com:user/repo
  if not host then
    -- ssh://git@github.com:22/user/repo, https://(user@)github.com/user/repo
    local rest = url:gsub("^%a+://", ""):gsub("^[^@/]+@", "")
    host, path = rest:match("^([^/:]+)[:%d]*/(.+)$")
  end
  return host and ("https://" .. host .. "/" .. path) or nil
end

-- URLを返す(コピーはしない)。作れない場合はnilと理由を返す(表示は呼び出し側で、エラーか警告かを決める)。
-- GitHub上の内容とずれる場合はcopy_warnで警告をためる。l1/l2を省略するとカーソル行(visualなら選択範囲)を使う
local function github_url(permalink, l1, l2)
  if not l1 then l1, l2 = current_line_range() end
  local file = vim.fn.resolve(vim.fn.expand("%:p")) -- シンボリックリンク経由で開いていても実体のリポジトリで判定する
  if file == "" then
    return nil, "ファイルではありません"
  end
  local dir = vim.fs.dirname(file)
  local path = git_out(dir, { "ls-files", "--full-name", "--", file })
  if not path or path == "" then
    return nil, "gitで管理されているファイルではありません"
  end
  local remote = git_out(dir, { "remote", "get-url", "origin" })
  local base = remote and remote_to_https(remote)
  if not base then
    return nil, "originのURLを解釈できません: " .. tostring(remote)
  end

  -- 比較先(GitHub上の内容)とURLに使うref
  local ref, compare, not_pushed
  if permalink then
    ref = git_out(dir, { "rev-parse", "HEAD" })
    compare = ref
    not_pushed = git_out(dir, { "branch", "-r", "--contains", ref }) == ""
  else
    -- 追跡しているリモートブランチ名を使う(ローカルとリモートでブランチ名が違っても正しく指す)
    local upstream = git_out(dir, { "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}" })
    if upstream then
      ref = upstream:gsub("^[^/]+/", "")
      compare = "@{u}"
    else
      ref = git_out(dir, { "branch", "--show-current" })
      if not ref or ref == "" then
        return nil, "ブランチ上にいません(detached HEAD)。,,fGを使ってください"
      end
      not_pushed = true
    end
  end

  local anchor = "#L" .. l1 .. (l2 ~= l1 and ("-L" .. l2) or "")
  -- Markdown等はGitHubがレンダリング表示するため、?plain=1を付けないと行番号のリンクが効かない
  local plain = path:match("%.md$") and "?plain=1" or ""
  local url = ("%s/blob/%s/%s%s%s"):format(base, ref, path, plain, anchor)

  -- GitHub上に無い/内容がずれる場合は警告(URLは作る)
  if not_pushed then
    copy_warn(permalink and "HEADが未push" or "ブランチが未push")
  elseif vim.bo.modified or git_out(dir, { "diff", "--quiet", compare, "--", file }) == nil then
    copy_warn("GitHubと差分あり") -- 行番号がずれる可能性がある
  end
  return url
end

local function copy_github_url(permalink)
  local label = permalink and "パーマリンクをコピー" or "GitHubのURLをコピー"
  local url, err = github_url(permalink)
  if url then
    copy_to_clipboard(label, url)
  else
    copy_fail(label, err)
  end
end
vim.keymap.set({ "n", "x" }, ",,fg", function() copy_github_url(false) end, vim.tbl_extend("force", copy_opts, { desc = "copy GitHub URL (branch)" }))
vim.keymap.set({ "n", "x" }, ",,fG", function() copy_github_url(true) end, vim.tbl_extend("force", copy_opts, { desc = "copy GitHub permalink" }))
-- ,,fgと同じURL(ブランチ名+行番号)をブラウザで開く。vim.ui.openはMacならopen、WSLならwslview/explorer.exeを使う
vim.keymap.set({ "n", "x" }, ",,fo", function()
  local url, err = github_url(false)
  if url then
    vim.ui.open(url)
    copy_done("GitHubで開く", url)
  else
    copy_fail("GitHubで開く", err)
  end
end, vim.tbl_extend("force", copy_opts, { desc = "open GitHub URL in browser" }))

-- リポジトリ直下からの相対パス(.config/nvim/init.lua)。gitの外ならカレントディレクトリからの相対パス
local function repo_relative_path()
  local file = vim.fn.resolve(vim.fn.expand("%:p"))
  local root = git_out(vim.fs.dirname(file), { "rev-parse", "--show-toplevel" })
  if root and vim.startswith(file, root .. "/") then
    return file:sub(#root + 2)
  end
  return vim.fn.expand("%:.")
end

-- リポジトリ直下からの相対パスをコピー
vim.keymap.set({ "n", "x" }, ",,fl", function()
  current_line_range() -- visualは抜けておく
  if vim.fn.expand("%:p") == "" then
    copy_fail("相対パスをコピー", "ファイルではありません")
    return
  end
  copy_to_clipboard("相対パスをコピー", repo_relative_path())
end, vim.tbl_extend("force", copy_opts, { desc = "copy repo relative path" }))

-- 「相対パス:行番号」と、その行(visualなら選択範囲)のコードをMarkdownのコードブロックにしてコピー。
-- Slack/Claude等に場所と言語名付きでコードを貼る用。言語名はfiletypeを使う。
-- with_linkなら「相対パス:行番号」をGitHubのパーマリンク(,,fGのURL)へのMarkdownリンクにする
local function copy_code_block(with_link)
  local label = with_link and "コードブロック(リンク付き)をコピー" or "コードブロックをコピー"
  local l1, l2 = current_line_range()
  if vim.fn.expand("%:p") == "" then
    copy_fail(label, "ファイルではありません")
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, l1 - 1, l2, false)
  -- コード中に```があってもコードブロックが途中で閉じないよう、それより長いフェンスにする
  local fence = "```"
  for _, l in ipairs(lines) do
    for ticks in l:gmatch("`+") do
      if #ticks >= #fence then fence = string.rep("`", #ticks + 1) end
    end
  end
  local loc = repo_relative_path() .. ":" .. l1 .. (l2 ~= l1 and ("-" .. l2) or "")
  local head = loc
  if with_link then
    -- URLを作れない(gitの管理外等)場合は、リンクなしの場所だけにして理由を警告する
    local url, err = github_url(true, l1, l2)
    if url then
      head = ("[%s](%s)"):format(loc, url)
    else
      copy_warn("リンクなし: " .. err)
    end
  end
  local text = table.concat({ head, fence .. vim.bo.filetype, table.concat(lines, "\n"), fence }, "\n")
  vim.fn.setreg("+", text)
  copy_done(label, head .. " (" .. (l2 - l1 + 1) .. "行)")
end
vim.keymap.set({ "n", "x" }, ",,fm", function() copy_code_block(true) end, vim.tbl_extend("force", copy_opts, { desc = "copy code block + permalink" }))
vim.keymap.set({ "n", "x" }, ",,fM", function() copy_code_block(false) end, vim.tbl_extend("force", copy_opts, { desc = "copy code block + path:line" }))

-- ファイルがあるディレクトリのフルパスをコピー
vim.keymap.set({ "n", "x" }, ",,fd", function() copy_file_path(":p:h", false, "ディレクトリをコピー") end, vim.tbl_extend("force", copy_opts, { desc = "copy directory full path" }))

-- ファイルがあるフォルダをFinder/エクスプローラーで開く。
-- WSLのexplorer.exeはLinuxのパスを解釈できないため、wslpathでWindowsのパスに変換して渡す
vim.keymap.set({ "n", "x" }, ",,fx", function()
  current_line_range() -- visualは抜けておく
  local dir = vim.fn.expand("%:p:h")
  if vim.fn.expand("%:p") == "" then dir = vim.fn.getcwd() end
  if vim.fn.has("wsl") == 1 and vim.fn.executable("explorer.exe") == 1 then
    local win = vim.trim(vim.fn.system({ "wslpath", "-w", dir }))
    vim.system({ "explorer.exe", win }) -- explorer.exeは成功しても終了コード1を返すので結果は見ない
  else
    vim.ui.open(dir)
  end
  copy_done("フォルダを開く", dir)
end, vim.tbl_extend("force", copy_opts, { desc = "open directory in file manager" }))

-- カーソル行(visualなら選択範囲)のLSP等の診断メッセージを「相対パス:行:列: 種別: メッセージ [ソース/コード]」でコピー
vim.keymap.set({ "n", "x" }, ",,fe", function()
  local l1, l2 = current_line_range()
  local diags = {}
  for lnum = l1, l2 do
    vim.list_extend(diags, vim.diagnostic.get(0, { lnum = lnum - 1 }))
  end
  if #diags == 0 then
    copy_fail("診断をコピー", "診断メッセージがありません")
    return
  end
  table.sort(diags, function(a, b)
    if a.lnum ~= b.lnum then return a.lnum < b.lnum end
    return a.severity < b.severity
  end)
  local path = vim.fn.expand("%:p") ~= "" and repo_relative_path() or vim.fn.bufname()
  local out = vim.tbl_map(function(d)
    local src = table.concat(vim.tbl_filter(function(x) return x ~= nil and x ~= "" end, { d.source, d.code and tostring(d.code) }), "/")
    return ("%s:%d:%d: %s: %s%s"):format(path, d.lnum + 1, d.col + 1, vim.diagnostic.severity[d.severity],
      d.message:gsub("\n", " "), src ~= "" and (" [" .. src .. "]") or "")
  end, diags)
  copy_to_clipboard("診断をコピー", table.concat(out, "\n"))
end, vim.tbl_extend("force", copy_opts, { desc = "diagnostics clipboard copy" }))

-- カーソル行(visualなら選択範囲)を最後に変更したコミットを取得する(git blame)。
-- 未保存の変更も反映させるため、バッファの内容を--contentsで渡す。未commitの行は除く
local function blame_commits(label)
  local l1, l2 = current_line_range()
  local file = vim.fn.resolve(vim.fn.expand("%:p"))
  if file == "" then
    copy_fail(label, "ファイルではありません")
    return
  end
  local dir = vim.fs.dirname(file)
  local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n") .. "\n"
  local r = vim.system({ "git", "-C", dir, "blame", "--porcelain", "-L", l1 .. "," .. l2, "--contents", "-", "--", file },
    { text = true, stdin = content }):wait()
  if r.code ~= 0 then
    copy_fail(label, "git blameに失敗しました: " .. vim.trim(r.stderr))
    return
  end
  local shas, seen, uncommitted = {}, {}, false
  for line in r.stdout:gmatch("[^\n]+") do
    -- ヘッダ行「<sha> <元の行> <今の行> [行数]」だけを拾う(コード行はタブ始まり)
    local sha = line:match("^(%x+) %d+ %d+")
    if sha and #sha == 40 and not seen[sha] then
      seen[sha] = true
      if sha:match("^0+$") then uncommitted = true else table.insert(shas, sha) end
    end
  end
  if #shas == 0 then
    copy_fail(label, uncommitted and "未commitの行だけです" or "コミットが見つかりません")
    return
  end
  if uncommitted then copy_warn("未commitの行は除外") end
  return dir, shas
end

-- 行を最後に変更したコミットの短いハッシュをコピー(範囲に複数あれば改行区切り)。通知にはコミットの件名も出す
vim.keymap.set({ "n", "x" }, ",,fH", function()
  local dir, shas = blame_commits("コミットハッシュをコピー")
  if not dir or not shas then return end
  local lines = vim.tbl_map(function(sha) return git_out(dir, { "log", "-1", "--format=%h", sha }) end, shas)
  vim.fn.setreg("+", table.concat(lines, "\n"))
  local subjects = vim.tbl_map(function(sha) return git_out(dir, { "log", "-1", "--format=%h %s", sha }) end, shas)
  copy_done("コミットハッシュをコピー", table.concat(subjects, "\n"))
end, vim.tbl_extend("force", copy_opts, { desc = "copy blame commit hash" }))

-- 行を最後に変更したコミットのGitHubのURLをコピー(範囲に複数あれば改行区切り)
vim.keymap.set({ "n", "x" }, ",,fh", function()
  local dir, shas = blame_commits("コミットのURLをコピー")
  if not dir or not shas then return end
  local remote = git_out(dir, { "remote", "get-url", "origin" })
  local base = remote and remote_to_https(remote)
  if not base then
    copy_fail("コミットのURLをコピー", "originのURLを解釈できません: " .. tostring(remote))
    return
  end
  for _, sha in ipairs(shas) do
    if git_out(dir, { "branch", "-r", "--contains", sha }) == "" then
      copy_warn(sha:sub(1, 7) .. "が未push")
    end
  end
  copy_to_clipboard("コミットのURLをコピー", table.concat(vim.tbl_map(function(sha) return base .. "/commit/" .. sha end, shas), "\n"))
end, vim.tbl_extend("force", copy_opts, { desc = "copy blame commit URL" }))

-- 全行コピー
vim.keymap.set("n", "yae", ":<C-u>%y<CR>", { noremap = true, desc = "yank all line" })
-- 全行削除
vim.keymap.set("n", "dae", ":<C-u>%d<CR>", { noremap = true, desc = "delete all line" })

-- 開いているバッファにlcd
vim.keymap.set("n", ",cd", ":<C-u>CD<CR>", { noremap = true, desc = "open file lcd" })
vim.cmd([[
command! -nargs=? -complete=dir -bang CD  call ChangeCurrentDirectory()
]])

-- 選択した範囲のインデントサイズを連続変更
vim.keymap.set("v", "<", "<gv", { noremap = true })
vim.keymap.set("v", ">", ">gv", { noremap = true })

-- 最後の保存からの変更をdiffで表示
-- Diffviewと同様に専用タブで開き(左:保存済み 右:編集中のバッファ)、qでタブごと閉じる。
-- 元の窓でdiffthisしないので、閉じた後に元の画面のdiff状態が残らない
local function diff_org()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" or vim.fn.filereadable(name) == 0 then
    vim.notify("DiffOrg: 保存済みのファイルがありません", vim.log.levels.WARN)
    return
  end
  local ft = vim.bo[buf].filetype

  vim.cmd("tab split")
  local tab = vim.api.nvim_get_current_tabpage()
  local edit_win = vim.api.nvim_get_current_win()
  vim.cmd("diffthis")
  vim.cmd("leftabove vnew")
  local sbuf = vim.api.nvim_get_current_buf()
  vim.bo[sbuf].buftype = "nofile"
  vim.bo[sbuf].bufhidden = "wipe"
  vim.bo[sbuf].swapfile = false
  -- ++editで元ファイルと同じfileencoding/fileformat判定で読み込む
  vim.cmd("silent read ++edit " .. vim.fn.fnameescape(name))
  vim.cmd("silent 0delete _")
  vim.bo[sbuf].modifiable = false
  vim.bo[sbuf].filetype = ft
  -- Diffview(enhanced_diff_hl)に合わせ、左(保存済み)にしかない行=削除行を赤で表示する
  vim.wo.winhighlight = "DiffAdd:DiffDelete"
  pcall(vim.api.nvim_buf_set_name, sbuf, "saved://" .. name)
  vim.cmd("diffthis")
  -- 右(編集中)の窓で一度カーソルを動かしてcursorbindで左の位置を合わせてから、左の窓に移る
  vim.cmd("wincmd p")
  vim.cmd("normal! 0")
  vim.cmd("wincmd p")

  local function close()
    if vim.api.nvim_tabpage_is_valid(tab) and #vim.api.nvim_list_tabpages() > 1 then
      vim.cmd("tabclose " .. vim.api.nvim_tabpage_get_number(tab))
    end
  end
  local opts = { noremap = true, silent = true, nowait = true, desc = "Close DiffOrg" }
  vim.keymap.set("n", "q", close, vim.tbl_extend("force", opts, { buffer = sbuf }))
  vim.keymap.set("n", "q", close, vim.tbl_extend("force", opts, { buffer = buf }))

  -- 保存済み側のバッファが消えたら(q/:q/:tabcloseのいずれでも)、編集中バッファに付けたqを外す
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = sbuf,
    once = true,
    callback = function()
      if vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.keymap.del, "n", "q", { buffer = buf })
      end
      vim.schedule(close)
    end,
  })
  -- 右側(編集中のバッファ)の窓を:qで閉じた場合もタブごと閉じる
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(edit_win),
    once = true,
    callback = function() vim.schedule(close) end,
  })
end
vim.api.nvim_create_user_command("DiffOrg", diff_org, {})
vim.keymap.set("n", "<Leader>d", diff_org, { noremap = true, silent = true, desc = "DiffOrg" })

-- 今のタブの窓をまとめてdiffthis/diffoffする。どれか1つでもdiff中なら解除、なければ開始。
-- neo-treeやquickfix、フロート窓などを巻き込まないよう、通常のファイルの窓だけを対象にする。
-- diff中はqでも解除できる。qはdiff中の窓でだけ解除として働き、それ以外では通常のq(マクロ記録)のまま。
-- (:diffoff!等で解除してqが残っても困らないように。解除時にまとめて外す)
-- 一番左の窓は変更前の扱いとし、Diffview(enhanced_diff_hl)に合わせて削除行(DiffAdd)を赤(DiffDelete)で表示する。
-- 元のwinhighlightを覚えておき、解除時に戻す
local diff_toggle_q_bufs = {}
local diff_toggle_left = nil -- { win = winid, orig = 元のwinhighlight }
local diff_toggle

local function diff_toggle_off()
  vim.cmd("diffoff!")
  for bufnr in pairs(diff_toggle_q_bufs) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      pcall(vim.keymap.del, "n", "q", { buffer = bufnr })
    end
  end
  diff_toggle_q_bufs = {}
  if diff_toggle_left and vim.api.nvim_win_is_valid(diff_toggle_left.win) then
    vim.wo[diff_toggle_left.win].winhighlight = diff_toggle_left.orig
  end
  diff_toggle_left = nil
end

function diff_toggle()
  local wins = vim.tbl_filter(function(w)
    local bt = vim.bo[vim.api.nvim_win_get_buf(w)].buftype
    return vim.api.nvim_win_get_config(w).relative == "" and (bt == "" or bt == "acwrite")
  end, vim.api.nvim_tabpage_list_wins(0))

  if vim.iter(vim.api.nvim_tabpage_list_wins(0)):any(function(w) return vim.wo[w].diff end) then
    diff_toggle_off()
    return
  end
  if #wins < 2 then
    vim.notify("DiffToggle: 比較するファイルの窓が2つ以上必要です", vim.log.levels.WARN)
    return
  end
  local left = wins[1]
  for _, w in ipairs(wins) do
    if vim.api.nvim_win_get_position(w)[2] < vim.api.nvim_win_get_position(left)[2] then left = w end
  end
  local orig = vim.wo[left].winhighlight
  diff_toggle_left = { win = left, orig = orig }
  vim.wo[left].winhighlight = orig == "" and "DiffAdd:DiffDelete" or (orig .. ",DiffAdd:DiffDelete")
  for _, w in ipairs(wins) do
    vim.api.nvim_win_call(w, function() vim.cmd("diffthis") end)
    local bufnr = vim.api.nvim_win_get_buf(w)
    -- 既にバッファローカルのqがある(DiffOrgやDiffview中など)場合は上書きしない
    local has_local_q = vim.api.nvim_buf_call(bufnr, function()
      return vim.fn.maparg("q", "n", false, true).buffer == 1
    end)
    if not has_local_q then
      vim.keymap.set("n", "q", function()
        if vim.wo.diff then
          vim.schedule(diff_toggle_off)
          return ""
        end
        return "q"
      end, { buffer = bufnr, expr = true, noremap = true, nowait = true, desc = "DiffToggle off / q" })
      diff_toggle_q_bufs[bufnr] = true
    end
  end
end
vim.api.nvim_create_user_command("DiffToggle", diff_toggle, {})
vim.keymap.set("n", "<Leader>D", diff_toggle, { noremap = true, silent = true, desc = "DiffToggle (diffthis/diffoff!)" })

-- visualで選択した範囲とクリップボード(+レジスタ)を専用タブで比べる(左:選択範囲 右:クリップボード)。
-- どちらも元のバッファとは切り離したコピー(nofile)。DiffOrgと同様にカーソルは左、qでタブごと閉じる
local function diff_clipboard()
  local sel = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  local clip = vim.fn.getreg("+", 1, true)
  if #clip == 0 or (#clip == 1 and clip[1] == "") then
    vim.notify("DiffClipboard: クリップボードが空です", vim.log.levels.WARN)
    return
  end
  -- WindowsからコピーしたCRLFのCRが残っていても差分にならないようにする
  clip = vim.tbl_map(function(l) return (l:gsub("\r$", "")) end, clip)
  local ft = vim.bo.filetype

  vim.cmd("tabnew")
  local tab = vim.api.nvim_get_current_tabpage()
  local function setup_buf(lines, label)
    local b = vim.api.nvim_get_current_buf()
    vim.bo[b].buftype = "nofile"
    vim.bo[b].bufhidden = "wipe"
    vim.bo[b].swapfile = false
    vim.api.nvim_buf_set_lines(b, 0, -1, false, lines)
    vim.bo[b].filetype = ft
    pcall(vim.api.nvim_buf_set_name, b, label .. "://" .. b)
    vim.cmd("diffthis")
    return b
  end
  local rbuf = setup_buf(clip, "clipboard")
  vim.cmd("leftabove vnew")
  local lbuf = setup_buf(sel, "selection")
  -- Diffview(enhanced_diff_hl)に合わせ、左にしかない行を赤で表示する
  vim.wo.winhighlight = "DiffAdd:DiffDelete"

  local function close()
    if vim.api.nvim_tabpage_is_valid(tab) and #vim.api.nvim_list_tabpages() > 1 then
      vim.cmd("tabclose " .. vim.api.nvim_tabpage_get_number(tab))
    end
  end
  for _, b in ipairs({ lbuf, rbuf }) do
    vim.keymap.set("n", "q", close, { buffer = b, noremap = true, silent = true, nowait = true, desc = "Close DiffClipboard" })
    -- 片方の窓を:qで閉じた場合もタブごと閉じる
    vim.api.nvim_create_autocmd("BufWipeout", { buffer = b, once = true, callback = function() vim.schedule(close) end })
  end
end
vim.keymap.set("x", "<Leader>D", diff_clipboard, { noremap = true, silent = true, desc = "Diff selection with clipboard" })

-- git
vim.keymap.set("n", "<Leader>gd", ":<C-u>DiffviewOpen<CR>", { noremap = true, silent = true, desc = "DiffviewOpen" })
vim.keymap.set("n", "<Leader>gH", ":<C-u>DiffviewFileHistory %<CR>", { noremap = true, silent = true, desc = "DiffviewFileHistory" })
-- 選択範囲の変更履歴(git log -L)。範囲を変更したコミットだけを差分付きで並べる。
-- ':'で自動入力される'<,'>をそのまま範囲として渡すため<C-u>は付けない
vim.keymap.set("x", "<Leader>gH", ":DiffviewFileHistory<CR>", { noremap = true, silent = true, desc = "DiffviewFileHistory (range)" })
vim.keymap.set('n', '<Leader>gh', function() require("fzf-lua").git_hunks({ ref = "HEAD" }) end, { noremap = true, silent = true, desc = "git hunks" })
-- ←:stage →:unstage。ctrl-xは分割ではなく変更の取り消し(untrackedはファイル削除)なので注意
vim.keymap.set('n', '<Leader>gs', function() require("fzf-lua").git_status({}) end, { noremap = true, silent = true, desc = "git status" })
-- 今のファイルのコミット履歴。プレビューはそのコミットでのこのファイルの差分。
-- Enter:その時点のファイルを開く(読み取り専用) ctrl-s/v/t:横分割/縦分割/タブで開く ctrl-y:ハッシュをコピー
vim.keymap.set('n', '<Leader>gc', function() require("fzf-lua").git_bcommits({}) end, { noremap = true, silent = true, desc = "git buffer commits" })

-- 折りたたみ
vim.keymap.set("n", "<Leader>a", "za", { noremap = true, silent = true, desc = "fold toggle" })

-- --------------------------------------------------
-- autocmd
-- --------------------------------------------------

-- ヤンクした範囲を一瞬(200ms)光らせる。どこをコピーしたかを分かるようにする
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function() vim.hl.on_yank({ timeout = 200 }) end,
})

-- 前回カーソル位置の復元
vim.cmd([[
augroup line_return
autocmd!
autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line('$') |
\     execute 'normal! g`"zvzz' |
\ endif
augroup end
]])

-- 起動時は常に変更なしとする（標準入力対策）
vim.cmd([[
augroup start_edit_none
autocmd!
autocmd VimEnter * setlocal nomodified
augroup end
]])

-- 改行時にコメントしない
vim.cmd([[
augroup new_line_comment_none_1
autocmd!
autocmd FileType * setlocal formatoptions-=ro
augroup end
]])

vim.cmd([[
augroup new_line_comment_none_1
autocmd!
autocmd CursorMoved * setlocal formatoptions-=ro
augroup end
]])

-- terminal でINSERTモードで開始
vim.cmd([[
augroup teminal_insert_start
autocmd!
autocmd TermOpen * startinsert | setlocal filetype=terminal
augroup end
]])

-- 折りたたみ設定
-- Folded/FoldColumnの色はvscode.nvim標準に戻した。切り戻す場合は下のhiをvim.cmdで実行する
--   hi Folded gui=bold term=standout ctermbg=LightGrey ctermfg=DarkBlue guibg=Grey30 guifg=Grey80
--   hi FoldColumn gui=bold term=standout ctermbg=LightGrey ctermfg=DarkBlue guibg=Grey guifg=DarkBlue
