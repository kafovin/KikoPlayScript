-- DbScrape
----------------
-- 公共部分
-- 脚本信息
info = {
    ["name"] = "TMDb",
    ["id"] = "Kikyou.l.TMDb",
    ["desc"] = "The Movie Database (TMDb) 脚本 （测试中，不稳定） Edited by: kafovin \n"..
                "从 themoviedb.org 刮削影剧元数据，也可设置选择刮削fanart的媒体图片、Emby的本地元数据。",
    --            "▲与前一版本不兼容▲ 建议搜索旧关联用`本地数据库`，仅刮削详旧资料细信息时设置`搜索-关键词作标题`为`1`。",
    ["version"] = "0.2.2" -- 0.2.2.220424_build
}
-- 设置项
-- `key`为设置项的`key`，`value`是一个`table`。设置项值`value`的类型都是字符串。
-- 由于加载脚本后的特性，在脚本中，可以直接通过`settings["xxxx"]`获取设置项的值。
settings = {
    ["api_key"] = {
        ["title"] = "API - TMDb的API密钥",
        ["default"] = "<<API_Key_Here>>",
        ["desc"] = "[必填项] 在`themoviedb.org`注册账号，并把个人设置中的API申请到的\n"..
                    "`API 密钥` (api key) 填入此项。 ( `https://www.themoviedb.org/settings/api`，一般为一串字母数字)"
    },
    ["api_key_fanart"] = {
        ["title"] = "API - fanart的API密钥",
        ["default"] = "<<API_Key_Here>>",
        ["desc"] = "[选填项] 在 `fanart.tv` 注册账号，并把页面`https://fanart.tv/get-an-api-key/`中申请到的\n"..
                    "`Personal API Keys` 填入此项。（一般为一串字母数字）\n"..
                    "注意：若需要跳过刮削fanart.tv的图片，请将设置项 `元数据 - 图片主要来源` 设为 `TMDb_only`。",
    },
    ["search_keyword_process"] = {
        ["title"] = "搜索 - 关键词处理",
        ["default"] = "filename",
        ["desc"] = "输入的字符经过何种处理作为关键词，来搜索媒体（不含集序号）。\n"..
                "filename：作为除去拓展名的文件名 (默认)。 plain：不处理，作为单纯的标题（搜索请不要输入季序号等）。", -- 丢弃`person`的演员搜索结果
        ["choices"] = "filename,plain",
    },
    ["search_keyword_astitle"] = {
        ["title"] = "搜索 - 关键词作标题",
        ["default"] = "0",
        ["desc"] = "搜索的关键词是否作为标题。\n 0：不使用 (默认)。 1：使用关键词作为标题。",
        ["choices"] = "0,1",
    },
    ["search_list_season_all"] = {
        ["title"] = "搜索 - 是否显示更多季",
        ["default"] = "1",
        ["desc"] = "搜索操作中 在没识别到季序号时，是否显示全部季数。\n".."当且仅当 `搜索 - 关键词处理` 设置为 `filename`时有效。\n"..
                "0：没识别到季序号时，仅显示第1季、或特别篇。 1：没识别到季序号时，显示全部季数 (默认)。", -- 丢弃`person`的演员搜索结果
        ["choices"] = "0,1",
    },
    ["search_type"] = {
        ["title"] = "搜索 - 媒体类型",
        ["default"] = "multi",
        ["desc"] = "搜索的数据仅限此媒体类型。\n movie：电影。 multi：电影/剧集 (默认)。 tv：剧集。", -- 丢弃`person`的演员搜索结果
        ["choices"] = "movie,multi,tv",
    },
    ["match_type"] = {
        ["title"] = "匹配 - 数据来源",
        ["default"] = "online_TMDb_filename",
        ["desc"] = "自动匹配本地媒体文件的数据来源。值为<local_Emby_nfo>时需要用软件Emby提前刮削过。\n" ..
                    "local_Emby_nfo：来自Emby在刮削TMDb媒体后 在本地媒体文件同目录存储元数据的 .nfo格式文件(内含.xml格式文本)；\n" ..
                    "online_TMDb_filename：(不稳定) 从文件名模糊识别关键词，再用TMDb的API刮削元数据 (默认)。 (*￣▽￣）", -- 丢弃`person`的演员搜索结果
        ["choices"] = "local_Emby_nfo,online_TMDb_filename",
    },
    ["match_priority"] = {
        ["title"] = "匹配 - 备用媒体类型",
        ["default"] = "multi",
        ["desc"] = "模糊匹配文件名信息时，类型待定的媒体以此类型匹配，仅适用于匹配来源为`online_TMDb_filename`的匹配操作。\n" ..
                    "此情况发生于文件名在描述 所有的电影、以及一些情况的剧集正篇或特别篇 的时候。\n" ..
                    -- "other：识别为`其他`类型的集（不同于本篇/特别篇），置于剧集特别篇或电影中。\n" ..
                    "movie：电影。multi：采用刮削时排序靠前的影/剧 (默认)。tv：剧集。single：以对话框确定影/剧某一种 (不稳定)。",
        ["choices"] = "movie,multi,single,tv",
                    -- "movie,multi,tv,movie_other,multi_other,tv_other"
    },
    ["metadata_lang"] = {
        ["title"] = "元数据 - 语言",
        ["default"] = "zh-CN",
        ["desc"] = "搜索何种语言的资料作元数据，选择你需要的`语言编码-地区编码`。看着有很多语言，其实大部分都缺乏资料。\n" ..
                    "注意：再次关联导致标题改变时，弹幕仍然按照旧标题识别，请在`管理弹幕池`中手动复制弹幕到新标题。\n" ..
                    "zh-CN：中文(中国)，(默认)。zh-HK：中文(香港特區,中國)。zh-TW：中文(台灣省，中國)。\n" ..
                    "en-US：English(US)。es-ES：español(España)。fr-FR：Français(France)。ja-JP：日本語(日本)。ru-RU：Русский(Россия)。",
        ["choices"] = "af-ZA,ar-AE,ar-SA,be-BY,bg-BG,bn-BD,ca-ES,ch-GU,cn-CN,cs-CZ,cy-GB,da-DK" ..
                    ",de-AT,de-CH,de-DE,el-GR,en-AU,en-CA,en-GB,en-IE,en-NZ,en-US,eo-EO,es-ES,es-MX,et-EE" ..
                    ",eu-ES,fa-IR,fi-FI,fr-CA,fr-FR,ga-IE,gd-GB,gl-ES,he-IL,hi-IN,hr-HR,hu-HU,id-ID,it-IT" ..
                    ",ja-JP,ka-GE,kk-KZ,kn-IN,ko-KR,ky-KG,lt-LT,lv-LV,ml-IN,mr-IN,ms-MY,ms-SG,nb-NO,nl-BE" ..
                    ",nl-NL,no-NO,pa-IN,pl-PL,pt-BR,pt-PT,ro-RO,ru-RU,si-LK,sk-SK,sl-SI,sq-AL,sr-RS,sv-SE" ..
                    ",ta-IN,te-IN,th-TH,tl-PH,tr-TR,uk-UA,vi-VN,zh-CN,zh-HK,zh-SG,zh-TW,zu-ZA",
        -- ["choices"] = "ar-SA,de-DE,en-US,es-ES,fr-FR,it-IT,ja-JP,ko-KR,pt-PT,ru-RU,zh-CN,zh-HK,zh-TW",
        -- ["choices"] = "en-US,fr-FR,ja-JP,ru-RU,zh-CN,zh-HK,zh-TW",
    },
    ["metadata_info_origin_title"] = {
        ["title"] = "元数据 - 标题使用原语言",
        ["default"] = "0",
        ["desc"] = "元数据的标题是否使用媒体的原语言。\n" ..
                    "注意：再次关联导致标题改变时，弹幕仍然按照旧标题识别，请在`管理弹幕池`中手动复制弹幕到新标题。\n"..
                    "0-不使用 (默认)。1-使用。",
        ["choices"] = "0,1",
    },
    ["metadata_info_origin_image"] = {
        ["title"] = "元数据 - 图片使用原语言",
        ["default"] = "1",
        ["desc"] = "元数据中fanart的图片是否使用媒体原语言，仅适用于fanart的图片。TMDb仍参照`元数据 - 语言`中的设置。\n"..
                    "不适用于 `元数据 - 图片主要来源` 设置为`TMDb_only`时，该选项仍参照以`元数据 - 语言`。\n" ..
                    "仅当 `元数据 - 图片主要来源` 设置为`fanart_prior`或`TMDb_prior`时 对fanart的图片有效。\n" ..
                    "0-不使用。1-使用 (默认)。",
        ["choices"] = "0,1",
    },
    ["metadata_display_imgtype"] = {
        ["title"] = "元数据 - 显示的图片种类",
        ["default"] = "background",
        ["desc"] = "仅限资料库媒体的右键菜单里`显示媒体元数据`弹出窗口中 所显示的那一张图片的种类。\n"..
                    "当 `元数据 - 图片主要来源` 设置为`TMDb_only`时，仅海报、背景可用。\n"..
                    "当 `元数据 - 图片主要来源` 设置为`fanart_prior`或`TMDb_prior`时，以下均有效（除非图片未刮削到）。\n" ..
                    "poster: 海报。banner: 横幅。thumb: 缩略图。background: 背景 (默认)。\n"..
                    "logo: 标志。art: 艺术图。otherart: 其他艺术图。",
                    -- "logo: 标志。logoL: 标志*。art: 艺术图。artL: 艺术图*。otherart: 其他艺术图。",
        ["choices"] = "poster,banner,thumb,background,logo,art,otherart",
        -- ["choices"] = "poster,banner,thumb,background,logo,logoL,art,artL,otherart",
    },
    ["metadata_image_priority"]={
        ["title"] = "元数据 - 图片主要来源",
        ["default"] = "TMDb_prior",
        ["desc"] = "元数据的图片源是使用TMDb还是fanart，需要各自的api密钥。\n"..
                    "其中，fanart的网络连接比较缓慢、图片种类更多 (可完全覆盖TMDb中所有图片种类)。\n"..
                    "fanart_prior：图片优先fanart，(由于fanart的图片种类较多，因此TMDb的图片通常会被忽略)。\n"..
                    "TMDb_only：图片仅TMDb，(不会从fanart刮削图片，仅此项不需要 fanart的API密钥)。\n"..
                    "TMDb_prior：图片优先TMDb，TMDb提供海报、背景，其他的由fanart提供 (默认)。",
        ["choices"] = "fanart_prior,TMDb_only,TMDb_prior",
    },
    ["metadata_castcrew_castcount"]={
        ["title"] = "元数据 - 演员总数至多为",
        ["default"] = "10",
        ["desc"] = "元数据的演员表至多保留多少演员 (默认 10)。\n"..
                    "其中，数目>0时，为至多保留的数目；数目=0时，不保留；数目<0时，保留所有；小数，则向负无穷方向取整。",
    },
    ["metadata_castcrew_crewcount"]={
        ["title"] = "元数据 - 职员总数至多为",
        ["default"] = "7",
        ["desc"] = "元数据的职员表至多保留多少职员 (默认 7)。\n"..
                    "其中，数目>0时，为至多保留的数目；数目=0时，不保留；数目<0时，保留所有；小数，则向负无穷方向取整。",
    },
}

-- 不会 在运行函数内更新值
Metadata_search_page = 1 -- 元数据搜索第几页。 默认：第 1 页
Metadata_search_adult = false -- Choose whether to inlcude adult content in the results when searching metadata. Default: false
-- 会  在运行函数内更新值
Metadata_info_origin_title = true -- 是否使用源语言标题
Metadata_info_origin_image = true -- 是否使用源语言图片 --仅fanart图片
Metadata_person_max_cast = 10 -- 演员表最多保留
Metadata_person_max_crew = 7 -- 职员表最多保留
Metadata_display_imgtype="background" -- 图片类型使用背景

Array={}
Kikoplus={}
Path={}
-- 说明: 三目运算符 ((condition) and {trueCDo} or {falseCDo})[1] === (condition)?(trueCDo):(falseCDo)
-- (()and{}or{})[1]

-- 媒体所属的流派类型，tmdb的id编号->类型名 的对应
Media_genre = {
    [28] = "动作", [12] = "冒险", [16] = "动画", [35] = "喜剧", [80] = "犯罪", [99] = "纪录",
    [18] = "剧情", [10751] = "家庭", [14] = "奇幻", [36] = "历史", [27] = "恐怖",
    [10402] = "音乐", [9648] = "悬疑", [10749] = "爱情", [878] = "科幻", [10770] = "电视电影",
    [53] = "惊悚", [10752] = "战争", [37] = "西部", [10759] = "动作冒险", [10762] = "儿童",
    [10763] = "新闻", [10764] = "真人秀", [10765] = "幻想", [10766] = "连续剧",
    [10767] = "脱口秀", [10768] = "War & Politics",
}
-- TMDb图片配置
Image_tmdb = {
    ["prefix"]= "https://image.tmdb.org/t/p/", -- 网址前缀
    -- path="https://image.tmdb.org/t/p/" .. "size" .. "/q1w2e3.png"
    ["min_ix"]= 2, -- 尺寸索引
    ["mid_ix"]= 5,
    ["max_ix"]= 7,
    ["backdrop"]= {"w300","w300","w780","w780","w1280","w1280","original"}, -- 影/剧剧照
    ["logo"]= {"w45","w92","w154","w185","w300","w500","original"}, -- /company/id - /network/id - 出品公司/电视网标志
    ["poster"]= {"w92","w154","w185","w342","w500","w780","original"}, -- 影/剧海报
    ["profile"]= {"w45","w45","w185","w185","h632","h632","original"}, -- /person/id 演员肖像
    ["still"]= {"w92","w92","w185","w185","w300","w300","original"}, -- /tv/id/season/sNum/episode/eNum 单集剧照
}
Image_fanart = {
    ["prefix"]= "https://assets.fanart.tv/",
    ["size"]= {"preview","fanart"},
    ["min_ix"]= 1, -- 尺寸索引
    ["mid_ix"]= 1,
    ["max_ix"]= 2,
    ["len_preix_size"]= 31, -- https://assets.fanart.tv/fanart (30) not https
    -- image_path="/movies/id/type/title-name-q1w2e3.png" "/tv/id/type/title-name-q1w2e3.png"
    ["movie"]={"movieposter","moviebanner","moviethumb","moviebackground",
                "hdmovielogo","movielogo","hdmovieclearart","movieart","moviedisc",},
    ["tv"]={"tvposter","tvbanner","tvthumb","showbackground",
                "hdtvlogo","clearlogo","hdclearart","clearart","characterart",},
    ["season"]={"seasonposter","seasonbanner","seasonthumb ","showbackground",},
    ["type_zh"]={
        ["movieposter"]="电影海报",["moviebanner"]="电影横幅",["moviethumb"]="电影缩略图",["moviebackground"]="电影背景",
        ["hdmovielogo"]="电影标志",["movielogo"]="电影标志*",["hdmovieclearart"]="电影艺术图",["movieart"]="电影艺术图*",["moviedisc"]="电影光盘",
        ["tvposter"]="剧集海报",["tvbanner"]="剧集横幅",["tvthumb"]="剧集缩略图",["showbackground"]="剧/季背景",
        ["hdtvlogo"]="剧集标志",["clearlogo"]="剧集标志*",["hdclearart"]="剧集艺术图",["clearart"]="剧集艺术图*",["characterart"]="剧集角色图",
        ["seasonposter"]="本季海报",["seasonbanner"]="本季横幅",["seasonthumb"]="本季缩略图",
    },
}
Status_tmdb = {
    ["Rumored"]= "传言中", ["Planned"]= "筹划中", ["In Production"]= "制作中", 
    ["Post Production"]= "已制作", ["Released"]= "已播映", ["Canceled"]="已取消",["Ended"]="已完结",[""]="",
}
--[[
-- 媒体信息<table>
Anime_data = {
    ["media_title"] = (mediai["media_title"]) or (mediai["media_name"]),		-- 标题
    ["original_title"] = (mediai["original_title"]) or (mediai["original_name"]),-- 原始语言标题
    ["media_id"] = tostring(mediai["id"]),			-- 媒体的 tmdb id
    ["media_imdbid"]            -- str:  ^tt[0-9]{7}$
    ["media_type"] = mediai["media_type"],			-- 媒体类型 movie tv person
    ["genre_ids"] = mediai["genre_ids"],			-- 流派类型的编号 table/Array
    ["genre_names"],			-- 流派类型 table/Array
    ["release_date"] = mediai["release_date"] or mediai["air_date"] or mediai["first_air_date"], -- 首映/本季首播/发行日期
    ["overview"] = mediai["overview"],				-- 剧情梗概 str
    ["overview_season"]
    ["tagline"]                 -- str
    ["vote_average"] = mediai["vote_average"],		-- 平均tmdb评分 num
    ["vote_count"]              -- 评分人数 num
    ["rate_mpaa"],				-- MPAA分级 str
    ["homepage_path"]           --主页网址 str
    ["status"]                  -- 发行状态 str
    ["popularity_num"]          -- 流行度 num
    ["runtime"]                 -- {num}
    ["imdb_id"]
    ["facebook_id"]
    ["instagram_id"]
    ["twitter_id"]
    ["tvdb_id"]

    ["original_language"] = mediai["original_language"], -- 原始语言 "en"
    ["spoken_language"]         -- {str:iso_639_1, str:name}
    ["tv_language"]            -- tv {"en"}
    ["origin_country"]      	-- tv 原始首播国家地区 {"US"}
    ["production_country"]      -- {str:iso_3166_1, str:name}
    ["production_company"],	    -- 出品公司 - {num:id, str:logo_path, str:name, str:origin_country}
    ["tv_network"],	        -- 播映剧集的电视网 - {...}
    --["person_staff"],			-- "job1:name1;job2;name2;..."
    --["tv_creator"]              -- {num:id, str:credit_id, str:name, 1/2:gender, str:profile_path}
    ["person_crew"]
    --["person_character"],		-- { ["name"]=string,   --人物名称 ["actor"]=string,  --演员名称 ["link"]=string,   --人物资料页URL  ["imgurl"]=string --人物图片URL }
    ["person_cast"]

    ["mo_is_adult"]             -- bool
    ["mo_is_video"]             -- bool
    ["mo_belongs_to_collection"]-- {}
    ["mo_budget"]               -- 预算 num
    ["mo_revenue"]              -- 收入 num

    ["season_count"],			-- 剧集的 总季数 num - 含 S00/Specials/特别篇/S05/Season 5/第 5 季
    ["season_number"],			-- 本季的 季序数 /第几季 num - 0-specials
    ["season_title"],			-- 本季的 季名称 str - "季 2" "Season 2" "Specials"
    ["episode_count"],			-- 本季的 总集数 num
    ["episode_total"],			-- 剧集所有季的 总集数 num
    ["tv_first_air_date"] = ["first_air_date"],		-- 剧集首播/发行日期 str
    ["tv_in_production"]        -- bool
    ["tv_last_air_date"]        -- str
    ["tv_last_episode_to_air"]  -- {num:episode_number, int:season_number, int:id, str:name, str:overview,
                                 str:air_date, str:production_code, str/nil:still_path, num:vote_average, int:vote_count}
    ["tv_next_episode_to_air"]  -- null or {...}
    ["tv_type"]                 -- str

    -- Image_tmdb.prefix..Image_tmdb.poster[Image_tmdb.max_ix] .. data["image_path"]
    ["poster_path"] = mediai["poster_path"] or tvSeasonsIx["poster_path"],		-- 海报图片 电影/剧集某季 str
    ["tv_poster_path"] = mediai["poster_path"],  -- 海报图片 剧集 str
    ["background_path"] = mediai["backdrop_path"],	-- 背景图片 电影/剧集 str
     ["fanart_path"] ={ [fanart_type] = { [origin]={url,lang,disc_type,season}, [interf]={} }, -- seasonX:"0"/all/others
    --
}]] --

---------------------
-- 资料脚本部分
-- copy (as template) from & thanks to "../library/bangumi.lua", "../danmu/bilibili.lua" in "KikoPlay/library"|KikoPlayScript
--

-- 完成搜索功能
-- keyword： string，搜索关键字
-- 返回：Array[AnimeLite]
function search(keyword)
    local settings_search_type=""
    if(settings["search_type"] ~= "movie" and settings["search_type"] ~= "tv") then
        settings_search_type="multi"
    else settings_search_type=settings["search_type"]
    end
    local mediais={}

    if settings["search_keyword_process"]=="plain" then
        if settings.search_keyword_astitle =="0" then
            mediais= searchMediaInfo(keyword,settings_search_type)
        elseif settings.search_keyword_astitle =="1" then
            mediais= searchMediaInfo(keyword,settings_search_type,keyword)
        end
    elseif true or settings["search_keyword_process"]=="filename" then
        local mType = "multi"
        local mTitle,mSeason,mEp,mEpX,mTitleX,mEpType = "","","","","",""
        local resMirbf= Path.getMediaInfoRawByFilename(keyword..".mkv")
        mTitle=resMirbf[1] or ""
        mSeason=resMirbf[2] or ""
        mEp=resMirbf[3] or ""
        mEpX=resMirbf[4] or ""
        mTitleX=resMirbf[5] or ""
        mEpType=resMirbf[6] or ""
        local mIsSp=false -- 是否为特别篇
        if mEpType~="" and mEpType~="EP" then
            mIsSp=true
        end
        if mEp~="" or mSeason~="" then
            mType="tv"
        else
            mType="multi"
        end

        local resultSearch
        if settings.search_keyword_astitle =="0" then
            resultSearch= searchMediaInfo(mTitle,
                ((settings_search_type=="multi")and{mType}or{settings_search_type})[1])
        elseif settings.search_keyword_astitle =="1" then
            resultSearch= searchMediaInfo(mTitle,
                ((settings_search_type=="multi")and{mType}or{settings_search_type})[1],keyword)
        end
        local mSeasonTv = ""
        local tmpsSearchlSeasonall= settings["search_list_season_all"]
        for _, value in ipairs(resultSearch or {}) do
            if mSeason =="" and value["media_type"] == "movie" then
                table.insert(mediais, value)
                goto continue_search_KMul_Mnfo
            elseif value["media_type"]=="tv" then
                if mSeason == "" then
                    if tmpsSearchlSeasonall=="0" then
                        mSeasonTv = ((mIsSp)and{0}or{1})[1]
                    elseif true or tmpsSearchlSeasonall=="1" then
                    end
                else mSeasonTv = math.floor(tonumber(mSeason))
                end
                if value["season_number"] == mSeasonTv or tostring(value["season_number"]) == tostring(mSeasonTv) then
                        table.insert(mediais, value)
                    goto continue_search_KMul_Mnfo
                elseif value["season_number"] == 0 or tostring(value["season_number"]) == tostring(0) or
                        value["season_number"] == 1 or tostring(value["season_number"]) == tostring(1) or
                        (string.isEmpty(mSeasonTv)) then
                    table.insert(mediais, value)
                    goto continue_search_KMul_Mnfo
                else
                    goto continue_search_KMul_Mnfo
                end
            end
            ::continue_search_KMul_Mnfo::--continue_match_OMul_Mnfo
        end
    end

    return mediais
end
function searchMediaInfo(keyword, settings_search_type, old_title)
    kiko.log("[INFO]  Searching <" .. keyword .. "> in " .. settings_search_type)
    -- 获取 是否 元数据使用原语言标题
    local miotTmp = settings['metadata_info_origin_title']
    if (miotTmp == '0') then
        Metadata_info_origin_title = false
    elseif (miotTmp == '1') then
        Metadata_info_origin_title = true
    end
    -- http get 请求 参数
    local query = {
        ["api_key"] = settings["api_key"],
        ["language"] = settings["metadata_lang"],
        ["query"] = keyword,
        ["page"] = Metadata_search_page,
        ["include_adult"] = Metadata_search_adult
    }
    local header = {["Accept"] = "application/json"}
    if settings["api_key"] == "<<API_Key_Here>>" then
        kiko.log("Wrong api_key! 请在脚本设置中填写正确的 TMDb的API密钥。")
        kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
        kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
    end
    -- 获取 http get 请求 - 查询特定媒体类型 特定关键字 媒体信息的 搜索结果列表
    if(settings_search_type ~= "movie" and settings_search_type ~= "tv") then
        settings_search_type="multi"
    end
    -- tmdb_search_multi
    local err, reply = kiko.httpget(string.format("http://api.themoviedb.org/3/search/" .. settings_search_type),
        query, header)
    if err ~= nil then
        kiko.log("[ERROR] TMDb.API.reply-search."..settings_search_type..".httpget: ".. err)
        if tostring(err) == ("Host requires authentication") then
            kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
            kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        end
        error(err)
    end
    --[[if reply["success"]=="false" or reply["success"]==false then
        err = reply["status_message"]
        kiko.log("[ERROR] TMDb.API.reply-search."..settings_search_type..": ".. err)
        error(err)
    end    ]]--
    -- json:reply -> Table:obj 获取的结果
    local content = reply["content"]
    local err, obj = kiko.json2table(content)
    if err ~= nil then
        kiko.log("[ERROR] TMDb.API.reply-search."..settings_search_type..".json2table: ".. err)
        error(err)
    end
    -- Table:obj["results"] 搜索结果<table> -> Array:mediai
    local mediais = {}
    for _, mediai in pairs(obj['results'] or {}) do
        if (mediai["media_type"] ~= 'tv' and mediai["media_type"] ~= 'movie' and settings_search_type == "multi") then
            -- 跳过对 演员 的搜索 - 跳过 person
            goto continue_search_a
        end
        -- 显示的媒体标题 title/name
        local mediaName
        if (Metadata_info_origin_title) then
            mediaName = string.unescape(mediai["original_title"] or mediai["original_name"])
        else
            mediaName = string.unescape(mediai["title"] or mediai["name"])
        end
        -- local extra = {}
        local data = {} -- 媒体信息
        -- 媒体类型
        if settings_search_type == "multi" then
            data["media_type"] = mediai["media_type"] -- 媒体类型 movie tv person
        elseif settings_search_type == "movie" then
            data["media_type"] = "movie"
        elseif settings_search_type == "tv" then
            data["media_type"] = "tv"
        else
            data["media_type"] = mediai["media_type"] -- 媒体类型 movie tv person
        end
        data["media_title"] = string.unescape(mediai["title"]) or string.unescape(mediai["name"]) -- 标题
        data["original_title"] = string.unescape(mediai["original_title"]) or string.unescape(mediai["original_name"]) -- 原始语言标题
        data["media_id"] = string.format("%d", mediai["id"]) -- 媒体的 tmdb id
        data["release_date"] = mediai["release_date"] or mediai["first_air_date"] -- 首映/首播/发行日期
        data["original_language"] = mediai["original_language"] -- 原始语言
        data["origin_country"] = table.deepCopy(mediai["origin_country"]) -- 原始首映/首播国家地区
        if not string.isEmpty(mediai.overview) and mediai.overview~=mediai.title and mediai.overview~=mediai.original_title then
            data["overview"] = (string.isEmpty(mediai.overview) and{""} or{ string.gsub(mediai["overview"], "\r?\n\r?\n", "\n") })[1] -- 剧情梗概
        end
        data["vote_average"] = mediai["vote_average"] -- 平均tmdb评分
        -- genre_ids -> genre_names
        data["genre_names"] = {} -- 流派类型 table/Array
        -- 流派类型 id ->名称
        for key, value in pairs(mediai["genre_ids"] or {}) do -- key-index value-id
            local genreIdIn = false -- genre_ids.value-id in Media_genre
            for k, v in pairs(Media_genre or {}) do
                if k == value then
                    genreIdIn = true
                end
            end
            if genreIdIn then
                data["genre_names"][key] = Media_genre[value]
            end
        end
        -- 图片链接
        if (mediai["poster_path"] ~= nil and mediai["poster_path"] ~= "") then
            data["poster_path"] = mediai["poster_path"]
        else
            data["poster_path"] = ""
        end
        if (mediai["backdrop_path"] ~= nil and mediai["backdrop_path"] ~= "") then
            data["background_path"] = mediai["backdrop_path"]
        else
            data["background_path"] = ""
        end
        --? OTHER_INFO
        -- data["vote_count"] = tonumber(mediai["vote_count"]or"")
        -- data["popularity_num"] = tonumber(mediai["popularity"]or"")
        -- data["mo_is_adult"]= (( mediai["adult"]==nil or mediai["adult"]=="" )and{ nil }or{ tostring(mediai["adult"])=="true" })[1]
        -- data["mo_is_video"]= (( mediai["video"]==nil or mediai["video"]=="" )and{ nil }or{ tostring(mediai["video"])=="true" })[1]

        -- season_number, episode_count,
        if data["media_type"] == "movie" then
            -- movie - 此条搜索结果是电影
            -- 把电影视为单集电视剧
            data["season_number"] = 1
            data["episode_count"] = 1
            data["season_count"] = 1
            data["season_title"] = data["original_title"]

            local queryMo = {
                ["api_key"] = settings["api_key"],
                ["language"] = settings["metadata_lang"]
            }
            -- info
            local objMo= Kikoplus.httpgetMediaId(queryMo,data["media_type"].."/"..data["media_id"])
            
            --? OTHER_INFO m&t of mo
            data["runtime"] = ( objMo["runtime"]==nil or objMo["runtime"]=="" )and{ nil }or{ tostring(objMo["runtime"]) }
            data["homepage_path"]= (( objMo["homepage"]==nil or objMo["homepage"]=="" )and{ nil }or{ objMo["homepage"] })[1]
            for index, value in ipairs(objMo["production_companies"] or {}) do
                data["production_company"]=data["production_company"]or{}
                table.insert(data["production_company"],{
                    -- ["id"]= tonumber(value["id"]or""),
                    -- ["logo_path"]= (( value["logo_path"]==nil or value["logo_path"]=="" )and{ nil }or{ value["logo_path"] })[1],
                    ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    ["origin_country"] = (( value["origin_country"]==nil or value["origin_country"]=="" )and{ nil }or{ value["origin_country"] })[1],
                })
            end
            for index, value in ipairs(objMo["production_countries"] or {}) do
                data["production_country"]=data["production_country"]or {}
                table.insert(data["production_country"],{
                    ["iso_3166_1"]= (( value["iso_3166_1"]==nil or value["iso_3166_1"]=="" )and{ nil }or{ value["iso_3166_1"] })[1],
                    -- ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                })
            end
            for index, value in ipairs(objMo["spoken_languages"] or {}) do
                data["spoken_language"]=data["spoken_language"]or {}
                table.insert(data["spoken_language"],{
                    ["iso_639_1"]= (( value["iso_639_1"]==nil or value["iso_639_1"]=="" )and{ nil }or{ value["iso_639_1"] })[1],
                    -- ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    -- ["english_name"]= (( value["english_name"]==nil or value["english_name"]=="" )and{ nil }or{ value["english_name"] })[1],
                })
            end
            data["status"]= (( objMo["status"]==nil or objMo["status"]=="" )and{ nil }or{ objMo["status"] })[1]
            --? OTHER_INFO mo
            data["mo_belongs_to_collection"] = table.deepCopy(objMo["belongs_to_collection"])
            data["mo_budget"] = tonumber(objMo["budget"]or"")
            data["media_imdbid"]= (( objMo["imdb_id"]==nil or objMo["imdb_id"]=="" )and{ nil }or{ objMo["imdb_id"] })[1]
            data["mo_revenue"] = tonumber(objMo["revenue"]or"")

            objMo.tagline= string.gsub(objMo.tagline or"", "[\n\r]", "")
            if string.isEmpty(objMo.tagline) or objMo.tagline==objMo.title or objMo.tagline==objMo.original_title then
                data.tagline= nil
            elseif true then
                data.tagline= string.gsub(objMo.tagline or"", "[\n\r]", "")
            end
            
            local media_data_json
            -- 把媒体信息<table>转为json的字符串
            err, media_data_json = kiko.table2json(table.deepCopy(data))
            if err ~= nil then
                kiko.log(string.format("[ERROR] table2json: %s", err))
            end
            -- kiko.log(string.format("[INFO]  mediaName: [ %s ], data:\n%s", mediaNameSeason, table.toStringBlock(data)));

            -- get "Movie Name (YYYY)"
            if data["release_date"] ~= nil and data["release_date"] ~= "" then
                mediaName = mediaName .. string.format(' (%s)', string.sub(data["release_date"], 1, 4))
            end
            local mediaLang={data["original_language"]}
            Array.extendUnique(mediaLang,data["spoken_language"],"iso_639_1")
            Array.extendUnique(mediaLang,data["tv_language"])
            local mediaCountry=table.deepCopy(data["origin_country"])
            Array.extendUnique(mediaCountry,data["production_country"],"iso_3166_1")

            table.insert(mediais, {
                ["name"] = (( string.isEmpty(old_title) )and{ mediaName }or{ old_title })[1],
                ["data"] = media_data_json,
                ["extra"] = "类型：" .. data["media_type"] .. "  |  首映：" ..
                    ((data["release_date"] or "") .. " " .. (data["first_air_date"] or "")) ..
                        "  |  语言：" .. Array.toStringLine(mediaLang) .. "  " .. Array.toStringLine(mediaCountry) ..
                    (data["original_language"] or "") .. "  " .. Array.toStringLine(data["origin_country"]) ..
                    "  |  状态：" .. (Status_tmdb[data["status"]] or data["status"] or "") ..
                    "\r\n简介：" .. string.gsub(data.overview or"", "\r?\n", " ")..
                    (( string.isEmpty(old_title) )and{ "" }or{ "\r\n弃用的标题：" ..mediaName })[1],
                ["scriptId"] = "Kikyou.l.TMDb",
                ["media_type"] = data["media_type"],
            })
        elseif data["media_type"] == "tv" then
            -- tv
            local queryTv = {
                ["api_key"] = settings["api_key"],
                ["language"] = settings["metadata_lang"]
            }
            local objTv=Kikoplus.httpgetMediaId(queryTv,data["media_type"] .. "/" .. data["media_id"])
            -- info
            
            data["tv_first_air_date"] = data["release_date"]
            data["tv_poster_path"] = data["poster_path"]
            data["season_count"] = objTv["number_of_seasons"]
            data["episode_total"] = objTv["number_of_episodes"]

            --? OTHER_INFO m&t of tv
            data["runtime"] = table.deepCopy(objTv["episode_run_time"])
            data["homepage_path"]= (( objTv["homepage"]==nil or objTv["homepage"]=="" )and{ nil }or{ objTv["homepage"] })[1]
            for index, value in ipairs(objTv["production_companies"] or {}) do
                data["production_company"]=data["production_company"] or {}
                table.insert(data["production_company"],{
                    -- ["id"]= tonumber(value["id"]or""),
                    -- ["logo_path"]= (( value["logo_path"]==nil or value["logo_path"]=="" )and{ nil }or{ value["logo_path"] })[1],
                    ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    ["origin_country"] = (( value["origin_country"]==nil or value["origin_country"]=="" )and{ nil }or{ value["origin_country"] })[1],
                })
            end
            for index, value in ipairs(objTv["production_countries"] or {}) do
                data["production_country"]=data["production_country"] or {}
                table.insert(data["production_country"],{
                    ["iso_3166_1"]= (( value["iso_3166_1"]==nil or value["iso_3166_1"]=="" )and{ nil }or{ value["iso_3166_1"] })[1],
                    -- ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                })
            end
            for index, value in ipairs(objTv["spoken_languages"] or {}) do
                data["spoken_language"]=data["spoken_language"] or {}
                table.insert(data["spoken_language"],{
                    ["iso_639_1"]= (( value["iso_639_1"]==nil or value["iso_639_1"]=="" )and{ nil }or{ value["iso_639_1"] })[1],
                    -- ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    -- ["english_name"]= (( value["english_name"]==nil or value["english_name"]=="" )and{ nil }or{ value["english_name"] })[1],
                })
            end
            data["status"]= (( objTv["status"]==nil or objTv["status"]=="" )and{ nil }or{ objTv["status"] })[1]
            --? OTHER_INFO tv
            for _, value in ipairs(objTv["created_by"] or {}) do
                data["person_crew"]=data["person_crew"] or {}
                table.insert(data["person_crew"],{
                    -- ["gender"]= (( tonumber(value["gender"])==1 or tonumber(value["gender"])==2 )and{ tonumber(value["gender"]) }or{ nil })[1],
                    ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    ["original_name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    ["profile_path"]= (( value["profile_path"]==nil or value["profile_path"]=="" )and{ nil }or{ value["profile_path"] })[1],
                    ["department"]= "Crew",
                    ["job"]="Creator",
                
                    ["id"] = tonumber(value["id"]or""),
                    -- ["credit_id"]= (( value["credit_id"]==nil or value["credit_id"]=="" )and{ nil }or{ value["credit_id"] })[1],
                })
            end
            data["tv_in_production"]= (( objTv["in_production"]==nil or objTv["in_production"]=="" )and{ nil }or{ tostring(objTv["in_production"])=="true" })[1]
            data["tv_language"] = table.deepCopy(objTv["languages"])
            -- data["tv_last_air_date"]= (( objTv["last_air_date"]==nil or objTv["last_air_date"]=="" )and{ nil }or{ objTv["last_air_date"] })[1]
            -- data["tv_last_episode_to_air"] = table.deepCopy(objTv["last_episode_to_air"])
            -- data["tv_next_episode_to_air"]= table.deepCopy(objTv["next_episode_to_air"])
            for index, value in ipairs(objTv["networks"] or {}) do
                data["tv_network"]=data["tv_network"] or {}
                table.insert(data["tv_network"],{
                    -- ["id"]= tonumber(value["id"]or""),
                    -- ["logo_path"]= (( value["logo_path"]==nil or value["logo_path"]=="" )and{ nil }or{ value["logo_path"] })[1],
                    ["name"]= (( value["name"]==nil or value["name"]=="" )and{ nil }or{ value["name"] })[1],
                    ["origin_country"] = (( value["origin_country"]==nil or value["origin_country"]=="" )and{ nil }or{ value["origin_country"] })[1],
                })
            end
            data["tv_type"]= (( objTv["type"]==nil or objTv["type"]=="" )and{ nil }or{ objTv["type"] })[1]

            objTv.tagline= string.gsub(objTv.tagline or"", "[\n\r]", "")
            if string.isEmpty(objTv.tagline) or objTv.tagline==objTv.title or objTv.tagline==objTv.original_title then
                data.tagline= nil
            elseif true then
                data.tagline= string.gsub(objTv.tagline or"", "\n", "")
            end
            
            -- Table:obj -> Array:mediai
            -- local tvSeasonsIxs = {}
            for _, tvSeasonsIx in pairs(objTv['seasons'] or {}) do
                data["tv_season_id"] = tonumber(mediai["id"]or"")

                local mediaNameSeason = mediaName -- 形如 "剧集名"
                data["release_date"] = tvSeasonsIx["air_date"] -- 首播日期
                data["season_title"] = tvSeasonsIx["name"]
                if not string.isEmpty(tvSeasonsIx.overview) and tvSeasonsIx.overview~=data.overview and
                        tvSeasonsIx.overview~=mediai.title and tvSeasonsIx.overview~=mediai.original_title then
                    data.overview_season = string.gsub(tvSeasonsIx.overview, "\r?\n\r?\n", "\n")
                end
                if (tvSeasonsIx["poster_path"] ~= nil and tvSeasonsIx["poster_path"] ~= "") then
                    data["poster_path"] = tvSeasonsIx["poster_path"]
                elseif (data["tv_poster_path"] ~= nil and data["tv_poster_path"] ~= "") then
                    data["poster_path"] = data["tv_poster_path"]
                else
                    data["poster_path"] = ""
                end

                data["season_number"] = math.floor(tvSeasonsIx["season_number"])
                data["episode_count"] = math.floor(tvSeasonsIx["episode_count"]) -- of this season

                local seasonNameNormal -- 是否为 普通的季名称 S00/Specials/特别篇/S05/Season 5/第 5 季
                seasonNameNormal = (data["season_title"] == string.format("Season %d", data["season_number"])) or
                                       (data["season_title"] == "Specials")
                seasonNameNormal = (data["season_title"] == string.format("第 %d 季", data["season_number"])) or
                                       (data["season_title"] == "特别篇") or seasonNameNormal
                seasonNameNormal = (data["season_title"] == string.format("第%d季", data["season_number"])) or
                                       (data["season_title"] == (string.format('S%02d', data["season_number"]))) or
                                       seasonNameNormal
                if seasonNameNormal then
                    if not (Metadata_info_origin_title) then
                        if tonumber(data["season_number"]) ~= 0 then
                            data.season_title= string.format('第%d季', data["season_number"])
                        else
                            data.season_title= '特别篇'
                        end
                    else
                        if tonumber(data["season_number"]) ~= 0 then
                            data.season_title= string.format('S%02d', data["season_number"])
                        else
                            data.season_title= 'Specials'
                        end
                    end
                else
                end
                mediaNameSeason = mediaNameSeason .. " " .. data.season_title
                -- 形如 "剧集名 第2季 (2010)"
                if data["release_date"] ~= nil and data["release_date"] ~= "" then
                    mediaNameSeason = mediaNameSeason .. string.format(' (%s)', string.sub(data["release_date"], 1, 4))
                end

                local media_data_json
                err, media_data_json = kiko.table2json(table.deepCopy(data))
                if err ~= nil then
                    kiko.log(string.format("[ERROR] table2json: %s", err))
                end
                -- kiko.log(string.format("[INFO]  mediaName: [ %s ], data:\n%s", mediaNameSeason, table.toStringBlock(data)));
                local seasonTextNormal = ""
                if data["season_number"] ~= 0 then
                    seasonTextNormal = string.format("第%02d季", data["season_number"] or "")
                else
                    seasonTextNormal = "特别篇"
                end
                local mediaLang={data["original_language"]}
                Array.extendUnique(mediaLang,data["spoken_language"],"iso_639_1")
                Array.extendUnique(mediaLang,data["tv_language"])
                local mediaCountry=table.deepCopy(data["origin_country"])
                Array.extendUnique(mediaCountry,data["production_country"],"iso_3166_1")
                local mediaLang={data["original_language"]}

                table.insert(mediais, {
                    ["name"] = (( string.isEmpty(old_title) )and{ mediaNameSeason }or{ old_title })[1] ,
                    ["data"] = media_data_json,
                    ["extra"] = "类型：" .. data["media_type"] .. "          |  首播：" ..
                        ((data["release_date"] or "") .. " " .. (data["first_air_date"] or "")) ..
                        "  |  语言：" .. Array.toStringLine(mediaLang) .. "  " .. Array.toStringLine(mediaCountry) ..
                        "  |  " .. seasonTextNormal .. string.format(" (共%2d季) ", data["season_count"] or "") ..
                        "  |  集数：" .. string.format("%d", data["episode_count"] or "") ..
                        "  |  状态：" .. (Status_tmdb[data["status"]] or data["status"] or "") ..
                        "\r\n简介：" .. ( string.isEmpty(data.overview_season) and{ "" }or
                                { string.gsub(data.overview_season or"", "\r?\n", " ") .."\r\n" })[1] ..
                            (string.gsub(data.overview or"", "\r?\n", " ") or "")..
                        (( string.isEmpty(old_title) )and{ "" }or{ "\r\n弃用的标题：" ..mediaNameSeason })[1],
                    ["scriptId"] = "Kikyou.l.TMDb",
                    ["media_type"] = data["media_type"],
                    ["season_number"] = data["season_number"],
                })
            end
        end

        ::continue_search_a::
    end
    kiko.log("[INFO]  Finished searching <" .. keyword .. "> with " .. #(obj['results']) .. " results in "..settings_search_type)
    -- kiko.log("[INFO]  Reults:\t" .. table.toStringBlock(mediais))
    return mediais
end

-- 获取动画的剧集信息。在调用这个函数时，anime的信息可能不全，但至少会包含name，data这两个字段。
-- anime： Anime
-- 返回： Array[EpInfo]
function getep(anime)
    --分集类型包括 EP, SP, OP, ED, Trailer, MAD, Other 七种，分别用1-7表示， 默认情况下为1（即EP，本篇）

    kiko.log("[INFO]  Getting episodes of <" .. anime["name"] .. ">")
    -- 获取 是否 元数据使用原语言标题
    local miotTmp = settings['metadata_info_origin_title']
    if (miotTmp == '0') then
        Metadata_info_origin_title = false
    elseif (miotTmp == '1') then
        Metadata_info_origin_title = true
    end
    -- 把媒体信息"data"的json的字符串转为<table>
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil then kiko.log(string.format("[ERROR] json2table: %s", err)) end
    -- number:季序数
    anime_data["season_number"] = math.floor(tonumber(anime_data["season_number"]))

    local eps = {}
    local epName, epIndex, epType = nil, nil, nil
    -- kiko.log(string.format("[INFO]  getting episode info ... %s - %s", anime_data["media_type"],type(anime_data["media_type"])))
    -- movie 假设为第一集，名称为标题
    if (anime_data["media_type"] == "movie") then
        -- 与标题语言要求相反的集标题
        -- if Metadata_info_origin_title==true then
        --     epName = anime_data["media_title"]
        -- else epName = anime_data["original_title"]
        -- end
        epName = anime_data["media_title"]
        epIndex = 1
        epType = 1
        table.insert(eps, {
            ["name"] = epName,
            ["index"] = epIndex,
            ["type"] = epType
        })
        -- kiko.log(string.format("[INFO]  Movie [%s] on Episode %d :[%s] %s", anime_data["original_title"], epIndex,epType, epName))
        -- tv
    elseif (anime_data["media_type"] == "tv") then

        -- http get 请求 参数
        local query = {
            ["api_key"] = settings["api_key"],
            ["language"] = settings["metadata_lang"]
        }
        local header = {["Accept"] = "application/json"}
        if settings["api_key"] == "<<API_Key_Here>>" then
            kiko.log("Wrong api_key! 请在脚本设置中填写正确的TMDb的API密钥。")
            kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
            kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
            error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
        end
        -- 获取 http get 请求 - 查询 特定tmdbid的剧集的 特定季序数的 媒体信息
        local err, reply = kiko.httpget(string.format("http://api.themoviedb.org/3/tv/" .. anime_data["media_id"] ..
                                                "/season/" .. (anime_data["season_number"])), query, header)

        if err ~= nil then
            kiko.log("[ERROR] TMDb.API.reply-getep.tv.id.season.httpget: " .. err)
            if tostring(err) == ("Host requires authentication") then
                kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
                kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
            end
            error(err)
        end
        -- json:reply -> Table:obj
        local content = reply["content"]
        local err, objS = kiko.json2table(content)
        if err ~= nil then
            kiko.log("[ERROR] TMDb.API.reply-getep.json2table: " .. err)
            error(err)
        end

        local normalEpTitle = false
        if (objS["episodes"] == nil or #(objS["episodes"]) == 0) then
            return eps
        end
        local seasonEpsI = objS["episodes"][1] -- 以第一集为例
        if seasonEpsI ~= nil then
            -- number:集序数
            seasonEpsI["episode_number"] = math.floor(tonumber(seasonEpsI["episode_number"]))
        end
        -- 对应单纯数字标题，而非有对应剧情名称的集标题
        if (seasonEpsI["name"] == "第 " .. seasonEpsI["episode_number"] .. " 集" or seasonEpsI["name"] == "第" ..
            seasonEpsI["episode_number"] .. "話" or seasonEpsI["name"] == "Episode " .. seasonEpsI["episode_number"]) then
            normalEpTitle = true
        end
        if (normalEpTitle and string.sub(query["language"], 1, 2) ~= anime_data["original_language"]) then
            -- 获取集标题
            -- and (query["language"] == "zh-CN" or query["language"] == "zh-HK" or query["language"] == "zh-TW" or query["language"] == "zh")
            query["language"] = anime_data["original_language"]
            -- 获取 http get 请求 - 查询 特定tmdbid的剧集的 特定季序数的 原语言的 媒体信息
            local err, replyO = kiko.httpget(string.format( "http://api.themoviedb.org/3/tv/" .. anime_data["media_id"] ..
                                                        "/season/" .. anime_data["season_number"]), query, header)
            if err ~= nil then
                kiko.log("[ERROR] TMDb.API.reply-getep.tv.id.season.lang.httpget: " .. err)
                if tostring(err) == ("Host requires authentication") then
                    kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
                    kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
                end
                error(err)
            end
            -- json:reply -> Table:obj
            local contentO = replyO["content"]
            local err, objSO = kiko.json2table(contentO)
            if err ~= nil then
                kiko.log("[ERROR] TMDb.API.reply-getep.tv.id.season.lang.json2table: " .. err)
                error(err)
            end
            local seasonEpsIO = objSO['episodes'][1]
            normalEpTitle = false
            seasonEpsIO["episode_number"] = math.floor(tonumber(seasonEpsIO["episode_number"]))
            if (seasonEpsIO["name"] == "第 " .. seasonEpsIO["episode_number"] .. " 集" or seasonEpsIO["name"] == "第" ..
                 seasonEpsIO["episode_number"] .. "話" or seasonEpsIO["name"] == "Episode " ..
                 seasonEpsIO["episode_number"]) then
                normalEpTitle = true
            end
            if (normalEpTitle ~= true) then
                objS = objSO
            end
        end
        for _, seasonEpsIx in pairs(objS['episodes'] or {}) do

            epName = seasonEpsIx["name"] -- 集标题
            epIndex = math.floor(tonumber(seasonEpsIx["episode_number"])) -- 集序数
            -- seasonEpsIx["air_date"]
            -- seasonEpsIx["overview"]
            -- seasonEpsIx["vote_average"]
            -- seasonEpsIx["crew"] --array
            -- seasonEpsIx["guest_stars"] --array

            -- 集类型
            if anime_data["season_number"] == 0 then
                -- 特别篇/Specials/Season 0
                epType = 2
            else
                -- 普通
                epType = 1
            end

            -- 插入搜索条目table到列表 eps
            table.insert(eps, {
                ["name"] = epName,
                ["index"] = epIndex,
                ["type"] = epType
            })
            -- kiko.log(string.format("[INFO]  TV [%s] on Episode %d :[%s] %s", anime_data["original_title"] ..string.format("S%02dE%02d", anime_data["season_number"], i), epIndex, epType, epName))
        end
    end
    if anime_data["media_type"] == "movie" then
        kiko.log("[INFO]  Finished getting " .. #eps .. " ep info of < " .. anime_data["media_title"] .. " (" ..
                 anime_data["original_title"] .. ") >")

    elseif anime_data["media_type"] == "tv" then
        kiko.log("[INFO]  Finished getting " .. #eps .. " ep info of < " .. anime_data["media_title"] .. " (" ..
                 anime_data["original_title"] .. ") " .. string.format("S%02d", anime_data["season_number"]) .. " >")
    end
    return eps
end

-- 获取动画详细信息
-- anime： AnimeLite
-- 返回：Anime
function detail(anime)
    kiko.log("[INFO]  Getting detail of <" .. anime["name"] .. ">")
    -- table.toStringLog(anime) -- kiko.log()
    -- 把媒体信息"data"的json的字符串转为<table>
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil then kiko.log(string.format("[ERROR] json2table: %s", err)) end
    -- kiko.log(string.format("[INFO]  getting media indetail ... %s - %s", anime_data["media_type"],type(anime_data["media_type"])))
    -- kiko.log("[INFO]  anime[\"data\"]=\"" .. anime["data"] .. "\" (" .. type(anime["data"]) .. ")")
    if anime_data == nil then
        -- 无媒体信息
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"] not found.")
        return anime
    end
    if anime_data["media_type"] == nil then
        -- 无媒体类型信息
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"][\"media_type\"] not found.")
        return anime
    end
    -- table.toStringLog(anime_data) -- kiko.log("")
    local miotTmp = settings['metadata_info_origin_title']
    if (miotTmp == '0') then
        Metadata_info_origin_title = false
    elseif (miotTmp == '1') then
        Metadata_info_origin_title = true
    end

    local titleTmp = "" -- 形如 "media_title (original_title)"
    if anime_data["media_title"] then
        titleTmp = titleTmp .. anime_data["media_title"]
        if anime_data["original_title"] then
            titleTmp = titleTmp .. " (" .. anime_data["original_title"] .. ")"
        end
    else
        if anime_data["original_title"] then
            titleTmp = titleTmp .. anime_data["original_title"]
        end
    end
    if tonumber(anime_data.season_number) then
        anime_data.season_number= math.floor(tonumber(anime_data.season_number))
    end
    if tonumber(anime_data.episode_count) then
        anime_data.season_number= math.floor(tonumber(anime_data.season_number))
    end

    if anime_data.season_title == string.format("第 %d 季", anime_data.season_number) then
        anime_data.season_title= string.format("第%d季", anime_data.season_number)
    end

    local objMl, objSl={}, {}
    if string.isEmpty(anime_data.tagline) or anime_data.tagline==anime_data.title or anime_data.tagline==anime_data.original_title then
        anime_data.tagline= nil
    end
    if string.isEmpty(anime_data.overview) or anime_data.overview==anime_data.title or anime_data.overview==anime_data.original_title then
        anime_data.overview=nil
    end
    if string.isEmpty(anime_data.tagline) or string.isEmpty(anime_data.overview) then
        objMl=Kikoplus.httpgetMediaId({
            ["api_key"] = settings["api_key"],
            ["language"] = (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1]
        },anime_data.media_type.."/"..anime_data.media_id)
        if (not string.isEmpty(objMl.tagline)) and string.isEmpty(anime_data.tagline) and
                objMl.tagline~=anime_data.title and objMl.tagline~=anime_data.original_title then
            anime_data.tagline= string.gsub(objMl.tagline or"", "\r?\n\r?\n", "\n")
        end
        if (not string.isEmpty(objMl.overview)) and string.isEmpty(anime_data.overview) and
                objMl.overview~=anime_data.title and objMl.overview~=anime_data.original_title then
            anime_data.overview= string.gsub(objMl.overview or"", "\r?\n\r?\n", "\n")
        end
    end
    if string.isEmpty(anime_data.overview_season) or anime_data.overview_season==anime_data.overview or
            anime_data.overview_season==anime_data.title or anime_data.overview_season==anime_data.original_title then
        anime_data.overview_season=nil
    end
    if string.isEmpty(anime_data.overview_season) and anime_data.media_type=="tv" then
        objSl=Kikoplus.httpgetMediaId({
            ["api_key"] = settings["api_key"],
            ["language"] = (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1]
        },anime_data.media_type.."/"..anime_data.media_id .. "/season/" .. anime_data.season_number)
        
        objSl.overview= string.gsub(objSl.overview or"", "\r?\n\r?\n", "\n")
        if (not string.isEmpty(objSl.overview)) and string.isEmpty(anime_data.overview_season) and objSl.overview~=(anime_data.overview or"") and
                objSl.overview~=anime_data.title and objSl.overview~=anime_data.original_title then
            anime_data.overview_season= objSl.overview
        end
    end
    -- string.gsub(anime_data.tagline or"", "\r?\n\r?\n", "\n")

    local queryCr = {
        ["api_key"] = settings["api_key"],
        ["language"] = settings["metadata_lang"]
    }
    local header = {["Accept"] = "application/json"}
    if settings["api_key"] == "<<API_Key_Here>>" then
        kiko.log("Wrong api_key! 请在脚本设置中填写正确的TMDb的API密钥。")
        kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
        kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
    end
    local err,replyCr
    if anime_data["media_type"]=="movie" then
        -- tmdb_id_mo_cr
        err, replyCr = kiko.httpget(string.format("http://api.themoviedb.org/3/" ..
            anime_data["media_type"] .. "/" .. anime_data["media_id"]).."/credits", queryCr, header)
    elseif anime_data["media_type"]=="tv" then
        -- tmdb_id_tv_s_cr
        err, replyCr = kiko.httpget(string.format(
            "http://api.themoviedb.org/3/" .. anime_data["media_type"] .. "/" .. anime_data["media_id"] ..
            "/season/" .. (anime_data["season_number"]).."/credits"), queryCr, header)
    end
    if err ~= nil then
        kiko.log("[ERROR] TMDb.API.reply-details."..anime_data["media_type"] .. ".id.credit.httpget: " .. err)
        if tostring(err) == ("Host requires authentication") then
            kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
            kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        end
        error(err)
    end
    local contentCr = replyCr["content"]
    local err, objCr = kiko.json2table(contentCr)
    if err ~= nil then
        kiko.log("[ERROR] TMDb.API.reply-details."..anime_data["media_type"] .. ".id.credit.json2table: " .. err)
        error(err)
    end
    
    local tmpAnimeCharacter, tmpMcCast,tmpMcCrew={}, 0,0
    tmpMcCast= math.floor(tonumber( settings["metadata_castcrew_castcount"] ) or Metadata_person_max_cast)
    if tmpMcCast<0 then tmpMcCast=math.maxinteger end
    Metadata_person_max_cast = math.max( tmpMcCast , math.floor(Metadata_person_max_cast))
    tmpMcCrew= math.floor(tonumber( settings["metadata_castcrew_crewcount"] ) or Metadata_person_max_crew)
    if tmpMcCrew<0 then tmpMcCrew=math.maxinteger end
    Metadata_person_max_crew = math.max( tmpMcCrew , math.floor(Metadata_person_max_crew))
    anime_data["person_cast"]={}
    -- anime_data["person_cast"]=anime_data["person_cast"] or {}
    for _, value in ipairs(objCr.cast or {}) do
        if #(anime_data["person_cast"])>=Metadata_person_max_cast then break end
        table.insert(anime_data["person_cast"],{
            -- ["gender"]= (( tonumber(value.gender)==1 or tonumber(value.gender)==2 )and{ tonumber(value.gender) }or{ nil })[1],
            ["name"]= (( string.isEmpty(value.name) )and{
                (( string.isEmpty(value.original_name))and{ nil }or{ value.original_name })[1] }or{ value.name })[1],
            ["original_name"]= (( string.isEmpty(value.original_name))and{ nil }or{ value.original_name })[1],
            ["profile_path"]= (( string.isEmpty(value.profile_path))and{ nil }or{ value.profile_path })[1],
            ["character"]= ( string.isEmpty(value.character) and{ nil }or{ value.character })[1],
            ["department"]= "Actors",
            ["job"]="Actor",
        
            -- ["adult"]= (( string.isEmpty(value.adult) )and{ nil }or{ value.adult })[1],
            ["id"] = tonumber(value.id or""),
            -- ["known_for_department"]= (( string.isEmpty(value.known_for_department)) and{ nil }or{ value.known_for_department })[1],
            -- ["popularity"]= tonumber(value.popularity or""),
            ["cast_id"]= tonumber(value.cast_id or""),
            -- ["credit_id"]= (( string.isEmpty(value.credit_id))and{ nil }or{ value.credit_id })[1],
            ["order"]= tonumber(value.order or""),
        })
        local tmpAnimeCharacterName=""
        if Metadata_info_origin_title then
            tmpAnimeCharacterName= ( string.isEmpty(value.original_name) and{ nil }or{ value.original_name})[1]
        else
            tmpAnimeCharacterName= ( string.isEmpty(value.original_name) and{ nil }or{
                (string.isEmpty(value.name) and{ value.original_name }or{ value.name })[1]})[1]
        end
        if #(anime_data["person_cast"])>tmpMcCast then goto continue_detail_ccc_cast end
        table.insert(tmpAnimeCharacter,{
            ["name"]= ( string.isEmpty(value.character) and{ nil }or{ value.character })[1],
            ["actor"]=tmpAnimeCharacterName,
            ["link"]="https://www.themoviedb.org/person/"..value.id,
            ["imgurl"]= (( string.isEmpty(value.profile_path))and{ nil }or{ 
                    Image_tmdb.prefix..Image_tmdb.profile[Image_tmdb.max_ix] .. value.profile_path })[1],
        })
        ::continue_detail_ccc_cast::
    end
    tmpAnimeCharacter= tmpAnimeCharacter or{} -- anime_data.person_cast.id = objCr.id
    local tmpAnimeStaff=""
    for _, value in ipairs(anime_data.person_crew or {}) do
        tmpAnimeStaff=tmpAnimeStaff ..( string.isEmpty(value.name) and{ "" }or{"Creator:".. value.name ..";" })[1]
    end
    anime_data["person_crew"]=anime_data.person_crew or {}
    -- anime_data["person_crew"]=anime_data["person_crew"] or {}
    for _, value in ipairs(objCr.crew or {}) do
        if #(anime_data["person_crew"])>=Metadata_person_max_crew then break end
        table.insert(anime_data["person_crew"],{
            -- ["gender"]= (( tonumber(value.gender)==1 or tonumber(value.gender)==2 )and{ tonumber(value.gender) }or{ nil })[1],
            ["name"]= (( string.isEmpty(value.name) )and{
                (( string.isEmpty(value.original_name))and{ nil }or{ value.original_name })[1] }or{ value.name })[1],
            ["original_name"]= (( string.isEmpty(value.original_name))and{ nil }or{ value.original_name })[1],
            ["profile_path"]= (( string.isEmpty(value.profile_path))and{ nil }or{ value.profile_path })[1],
            ["department"]= (( string.isEmpty(value.department))and{ nil }or{ value.department })[1],
            ["job"]= (( string.isEmpty(value.job) )and{ nil }or{ value.job })[1],
            
            -- ["adult"]= (( string.isEmpty(value.adult) )and{ nil }or{ value.adult })[1],
            ["id"] = tonumber(value.id or""),
            -- ["known_for_department"]= (( string.isEmpty(value.known_for_department)) and{ nil }or{ value.known_for_department })[1],
            -- ["popularity"]= tonumber(value.popularity or""),
            -- ["credit_id"]= (( string.isEmpty(value.credit_id))and{ nil }or{ value.credit_id })[1],
        })
        if #(anime_data["person_crew"])>tmpMcCrew then goto continue_detail_ccc_crew end
        if (not string.isEmpty(value.original_name)) or (not string.isEmpty(value.name)) then
            if Metadata_info_origin_title then
                tmpAnimeStaff= tmpAnimeStaff ..(value.department.." - "..value.job) ..":"..
                            ( string.isEmpty(value.original_name) and{ value.name }or{value.name })[1] ..";"
            else
                tmpAnimeStaff= tmpAnimeStaff ..(value.department.." - "..value.job) ..":"..
                            ( string.isEmpty(value.name) and{ value.original_name }or{value.name })[1] ..";"
            end
        end
        ::continue_detail_ccc_crew::
    end
    tmpAnimeStaff= tmpAnimeStaff or "" -- anime_data.person_crew.id = objCr.id
    local queryEi = {
        ["api_key"] = settings["api_key"],
        ["language"] = settings["metadata_lang"]
    }
    if settings["api_key"] == "<<API_Key_Here>>" then
        kiko.log("Wrong api_key! 请在脚本设置中填写正确的TMDb的API密钥。")
        kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
        kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
    end
    local replyEi
    -- tmdb_id_mo_cr
    err, replyEi = kiko.httpget(string.format("http://api.themoviedb.org/3/" ..
            anime_data["media_type"] .. "/" .. anime_data["media_id"]).."/external_ids", queryEi, header)
    if err ~= nil then
        kiko.log("[ERROR] TMDb.API.reply-details."..anime_data["media_type"] .. ".id.xid.httpget: " .. err)
        if tostring(err) == ("Host requires authentication") then
            kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
            kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        end
        error(err)
    end
    local contentEi = replyEi["content"]
    local err, objEi = kiko.json2table(contentEi)
    if err ~= nil then
        kiko.log("[ERROR] TMDb.API.reply-details."..anime_data["media_type"] .. ".id.xid.json2table: " .. err)
        error(err)
    end

    anime_data.imdb_id= ( string.isEmpty(objEi.imdb_id) and{ nil }or{ objEi.imdb_id })[1]
    anime_data.facebook_id= ( string.isEmpty(objEi.facebook_id) and{ nil }or{ objEi.facebook_id })[1]
    anime_data.instagram_id= ( string.isEmpty(objEi.instagram_id) and{ nil }or{ objEi.instagram_id })[1]
    anime_data.twitter_id= ( string.isEmpty(objEi.twitter_id) and{ nil }or{ objEi.twitter_id })[1]
    if anime_data.media_type=="tv" then
        anime_data.tvdb_id= ((objEi.tvdb_id ==nil)and{nil}or{tostring(math.floor(tonumber(objEi.tvdb_id)))})[1]
    end

    local mImgPTmp = "TMDb_prior"
    if settings["metadata_image_priority"]=="fanart_prior"
        or settings["metadata_image_priority"]=="TMDb_only"
        or settings["metadata_image_priority"]=="TMDb_prior" then
        mImgPTmp= settings["metadata_image_priority"]
    end
    if mImgPTmp=="fanart_prior" or mImgPTmp=="TMDb_prior" then
        local queryFan = {
            ["api_key"] = settings["api_key_fanart"]
        }
        if settings["api_key_fanart"] == "<<API_Key_Here>>" then
            kiko.log("Wrong api_key! 请在脚本设置中填写正确的 `fanart的API密钥`。")
            kiko.message("[错误] 请在脚本设置中填写正确的 `fanart的API密钥`！\n"..
                    "或把设置项`元数据 - 图片主要来源`改为`TMDb_only`以取消从fanart刮削。",1|8)
            kiko.execute(true, "cmd", {"/c", "start", "https://fanart.tv/get-an-api-key/"})
            goto jumpover_fanart_scraping
        end
        local replyFan
        if anime_data["media_type"]=="movie" then
            -- tmdb_id_mo_cr
            err, replyFan = kiko.httpget(string.format("https://webservice.fanart.tv/v3/movies/" ..
                anime_data["media_id"]), queryFan, header)
        elseif anime_data["media_type"]=="tv" and (not string.isEmpty(anime_data["tvdb_id"])) then
            -- tmdb_id_tv_s_cr
            err, replyFan = kiko.httpget(string.format("https://webservice.fanart.tv/v3/tv/" ..
                anime_data["tvdb_id"]), queryFan, header)
        else
            goto jumpover_fanart_scraping
        end
        if err ~= nil then
            kiko.log("[ERROR] fanart.API.reply-details."..anime_data["media_type"] .. ".httpget: " .. err)
            if tostring(err) == ("Host requires authentication") then
                kiko.message("[错误] 请在脚本设置中填写正确的 `fanart的API密钥`！\n"..
                        "或把设置项`元数据 - 图片主要来源`改为`TMDb_only`以取消从fanart刮削。",1|8)
                kiko.execute(true, "cmd", {"/c", "start", "https://fanart.tv/get-an-api-key/"})
            end
            goto jumpover_fanart_scraping
        end
        local contentFan = replyFan["content"]
        local err, objFan = kiko.json2table(contentFan)
        if err ~= nil then
            kiko.log("[ERROR] fanart.API.reply-details."..anime_data["media_type"] .. ".json2table: " .. err)
            error(err)
        end

        local originLang=anime_data.original_language
        if string.isEmpty(originLang) then
            originLang= (table.isEmpty(anime_data.spoken_language) and{originLang}or{anime_data.spoken_language[1]["iso_639_1"]})[1]
        end
        if string.isEmpty(originLang) and anime_data.media_type=="tv" then
            originLang= (table.isEmpty(anime_data.tv_language) and{originLang}or{anime_data.tv_language[1]})[1]
        end
        originLang= (string.isEmpty(originLang) and{""}or{originLang})[1]
        local interfLang=string.sub(settings["metadata_lang"],1,2)
        -- [""]= ( string.isEmpty(value.) and{ nil }or{ value. })[1],
        -- [""]= ( string.isEmpty(value.) and{ nil }or{ tostring(value.)=="true" })[1],
        -- [""]= tonumber(value. or""),
        anime_data["fanart_path"]={}
        local imgPathVoine={}
        local function getFti(value)
            if string.isEmpty(value.url) then
                return nil
            end
            return {
            -- ["id"]= ( string.isEmpty(value.id) and{ nil }or{ value.id })[1],
            ["url"]= ( string.isEmpty(value.url) and{ nil }or{
                string.sub(value.url,Image_fanart.len_preix_size,-1) })[1],
            ["lang"]= ( string.isEmpty(value.lang) and{ nil }or{ value.lang })[1],
            -- ["likes"]= ( string.isEmpty(value.likes) and{ nil }or{ value.likes })[1],
            -- ["disc"]= ( string.isEmpty(value.disc) and{ nil }or{ value.disc })[1],
            ["disc_type"]= ( string.isEmpty(value.disc_type) and{ nil }or{ value.disc_type })[1],
            ["season"]= ( string.isEmpty(value.season) and{ nil }or{ value.season })[1],
        } end
        -- origin-origin  interf-interface  noLang-no.lang  en-en
        local miotTmp = settings['metadata_info_origin_title']
        if (miotTmp == '0') then
            Metadata_info_origin_image = false
        elseif (miotTmp == '1') then
            Metadata_info_origin_image = true
        end
        for _,fti in ipairs(Image_fanart[anime_data.media_type]) do
            imgPathVoine={}
            for _, value in ipairs(objFan[fti] or{}) do
                if #imgPathVoine>=4 then
                    break
                end
                if string.isEmpty(value.url) or tonumber(value.season or "")~=nil then
                    goto continue_detail_fan_mfti
                end
                if(imgPathVoine.origin==nil and value.lang==originLang) then
                    imgPathVoine.origin= getFti(value)
                end
                if(imgPathVoine.interf==nil and value.lang==interfLang) then
                    imgPathVoine.interf= getFti(value)
                end
                if(imgPathVoine.noLang==nil and (value.lang=="00" or string.isEmpty(value.lang))) then
                    imgPathVoine.noLang= getFti(value)
                end
                if(imgPathVoine.en==nil and value.lang=="en") then
                    imgPathVoine.en= getFti(value)
                end
                ::continue_detail_fan_mfti::
            end
            (anime_data.fanart_path or{})[fti]={}
            (anime_data.fanart_path or{})[fti]["origin"]=imgPathVoine.origin or imgPathVoine.noLang
            if Metadata_info_origin_image==true then
                (anime_data.fanart_path or{})[fti]["interf"]= imgPathVoine.origin or
                        imgPathVoine.noLang or imgPathVoine.interf or imgPathVoine.en
            else
                (anime_data.fanart_path or{})[fti]["interf"]=
                        imgPathVoine.interf or imgPathVoine.noLang or imgPathVoine.en
            end
        end
        local imgPathSoine={}
        if anime_data.media_type=="tv" then
            for _,fti in ipairs(Image_fanart.season) do
                imgPathSoine={}
                for _, value in ipairs(objFan[fti] or{}) do
                    if #imgPathSoine>=4 then
                        break
                    end
                    if string.isEmpty(value.url) or not (tonumber(value.season)~=nil
                            and tonumber(value.season)== tonumber(anime_data.season_number)) then
                        goto continue_detail_fan_tfti
                    end
                    if string.isEmpty(value.season) then
                        value.season=""
                    end
                    if(imgPathSoine.origin==nil and value.lang==originLang) then
                        imgPathSoine.origin= table.deepCopy(getFti(value))
                    end
                    if(imgPathSoine.interf==nil and value.lang==interfLang) then
                        imgPathSoine.interf= table.deepCopy(getFti(value))
                    end
                    if(imgPathSoine.noLang==nil and (value.lang=="00" or string.isEmpty(value.lang))) then
                        imgPathSoine.noLang= table.deepCopy(getFti(value))
                    end
                    if(imgPathSoine.en==nil and value.lang=="en") then
                        imgPathSoine.en= table.deepCopy(getFti(value))
                    end
                    ::continue_detail_fan_tfti::
                end
                (anime_data.fanart_path or{})[fti]={}
                (anime_data.fanart_path or{})[fti]["origin"]=table.deepCopy(imgPathSoine.origin or imgPathSoine.noLang)
                if Metadata_info_origin_image==true then
                    (anime_data.fanart_path or{})[fti]["interf"]= table.deepCopy(imgPathSoine.origin or
                            imgPathSoine.noLang or imgPathSoine.interf or imgPathSoine.en)
                else
                    (anime_data.fanart_path or{})[fti]["interf"]=
                            table.deepCopy(imgPathSoine.interf or imgPathSoine.noLang or imgPathSoine.en)
                end
            end
        end
    end
    ::jumpover_fanart_scraping::
    local posterUrlTmp = ""
    if mImgPTmp=="TMDb_prior" or mImgPTmp=="TMDb_only" then
        posterUrlTmp = anime_data["poster_path"]
        if not string.isEmpty(posterUrlTmp) then
            posterUrlTmp = Image_tmdb.prefix..Image_tmdb.poster[Image_tmdb.max_ix] .. posterUrlTmp
        end
    end
    if mImgPTmp=="fanart_prior" or (string.isEmpty(posterUrlTmp) and mImgPTmp=="TMDb_prior") then
        if anime_data.media_type=="tv" then
            if Metadata_info_origin_image==true then
                posterUrlTmp = ((((anime_data.fanart_path or{})[Image_fanart["season"][1]] or{}).origin or{}).url or"")
            else
                posterUrlTmp = ((((anime_data.fanart_path or{})[Image_fanart["season"][1]] or{}).interf or{}).url or"")
            end
        end
        if not string.isEmpty(posterUrlTmp) then
            posterUrlTmp = Image_fanart.prefix..Image_fanart.size[2]..posterUrlTmp
        else
            if Metadata_info_origin_image==true then
                posterUrlTmp = ((((anime_data.fanart_path or{})[Image_fanart[anime_data.media_type][1]] or{}).origin or{}).url or"")
            else
                posterUrlTmp = ((((anime_data.fanart_path or{})[Image_fanart[anime_data.media_type][1]] or{}).interf or{}).url or"")
            end
            if not string.isEmpty(posterUrlTmp) then
                posterUrlTmp = Image_fanart.prefix..Image_fanart.size[2]..posterUrlTmp
            elseif mImgPTmp=="fanart_prior" then
                posterUrlTmp = anime_data["poster_path"]
                if not string.isEmpty(posterUrlTmp) then
                    posterUrlTmp = Image_tmdb.prefix..Image_tmdb.poster[Image_tmdb.max_ix] .. posterUrlTmp
                end
            end
        end
    end
    -- kiko.log(table.toStringBlock(anime_data))
    local err, media_data_json = kiko.table2json(table.deepCopy(anime_data))
    if err ~= nil then
        kiko.log(string.format("[ERROR] table2json: %s", err))
    end
    -- kiko.log("[TEST]  "..posterUrlTmp)
    local animePlus = {
        ["name"] = anime["name"],
        ["data"] = media_data_json,
        ["url"] = ((not string.isEmpty(anime_data["media_type"])) and {"https://www.themoviedb.org/" ..
                 anime_data["media_type"] .. "/" .. anime_data["media_id"]} or {""})[1], -- 条目页面URL
        ["desc"] = (( string.isEmpty(anime_data.tagline) )and{ "" }or { anime_data.tagline .."\n\n" })[1] ..
                    (( string.isEmpty(anime_data.overview_season) )and{ "" }or { anime_data.overview_season .."\n\n" })[1] ..
                    anime_data["overview"] .."\n\n".. titleTmp, -- 描述
        ["airdate"] = ((anime_data["release_date"]) and {
                 anime_data["release_date"]} or {anime_data["tv_first_air_date"]})[1] or "", -- 发行日期，格式为yyyy-mm-dd 
        ["epcount"] = anime_data["episode_count"], -- 分集数
        ["coverurl"] = posterUrlTmp,
        ["staff"] = tmpAnimeStaff, -- staff - "job1:staff1;job2:staff2;..."
        ["crt"] = tmpAnimeCharacter, -- 人物
        ["scriptId"] = "Kikyou.l.TMDb"
    }
    if anime_data["media_type"] == "movie" then
        kiko.log("[INFO]  Finished getting detail of < " .. anime_data["media_title"] ..
                     " (" .. anime_data["original_title"] .. ") >")

    elseif anime_data["media_type"] == "tv" then
        kiko.log("[INFO]  Finished getting detail of < " .. anime_data["media_title"] .. " (" ..
                     anime_data["original_title"] .. ") " .. string.format("S%02d", anime_data["season_number"]) .. ">")
    end
    -- kiko.log("[INFO]  Anime = " .. table.toStringBlock(animePlus))
    return animePlus
end

-- 获取标签
-- anime： Anime
-- 返回： Array[string]，Tag列表
function gettags(anime)
    -- KikoPlay支持多级Tag，用"/"分隔，你可以返回类似“动画制作/A1-Pictures”这样的标签
    kiko.log("[INFO]  Starting getting tags of <" .. anime["name"]..">")
    -- table.toStringLog(anime) -- kiko.log()
    -- 把媒体信息"data"的json的字符串转为<table>
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil then kiko.log(string.format("[ERROR] json2table: %s", err)) end
    -- kiko.log(string.format("[INFO]  getting media indetail ... %s - %s", anime_data["media_type"],type(anime_data["media_type"])))
    -- kiko.log("[INFO]  anime[\"data\"]=\"" .. anime["data"] .. "\" (" .. type(anime["data"]) .. ")")
    if anime_data == nil then
        -- 无媒体信息
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"] not found.")
        return anime
    end
    if anime_data["media_type"] == nil then
        -- 无媒体类型信息
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"][\"media_type\"] not found.")
    end
    -- table.toStringLog(anime_data) -- kiko.log("")
    local mtag = {} -- 标签数组
    local genre_name_tmp -- 暂存字符串

    for _, value in pairs(anime_data["genre_names"] or {}) do
        if (value ~= nil) then
            genre_name_tmp = value .. ""
            table.insert(mtag, "流派/"..genre_name_tmp)
        end
    end
    if anime_data["mo_is_adult"]==true or anime_data["mo_is_adult"]=="true" then
        table.insert(mtag, "流派/成人")
    end

    if anime_data["media_type"] == "movie" then
        table.insert(mtag, "媒体类型/电影")

    elseif anime_data["media_type"] == "tv" then
        table.insert(mtag, "媒体类型/剧集")
    else
        table.insert(mtag, "媒体类型/其他")
    end
    if anime_data["tv_type"]~=nil and anime_data["tv_type"]~="" then
        table.insert(mtag, "媒体类型/" .. anime_data["tv_type"])
    end
    if not string.isEmpty(anime_data["status"]) then
        table.insert(mtag, "播映状态/" .. (Status_tmdb[anime_data["status"] or""] or anime_data["status"] or ""))
    end
    if anime_data["tv_in_production"]==true or anime_data["tv_in_production"]=="true" then
        table.insert(mtag, "播映状态/更新中")
    end
    local mediaLang= {anime_data["original_language"]}
    Array.extendUnique(mediaLang,anime_data["spoken_language"],"iso_639_1")
    Array.extendUnique(mediaLang,anime_data["tv_language"])
    local mediaCountry= table.deepCopy(anime_data["origin_country"])
    Array.extendUnique(mediaCountry,anime_data["production_country"],"iso_3166_1")
    local mediaCompany={}
    Array.extendUnique(mediaCompany,anime_data["production_company"],"name")
    -- Array.extendUnique(mediaCompany,anime_data["tv_network"],"name")
    local mediaNetwork={}
    Array.extendUnique(mediaNetwork,anime_data["tv_network"],"name")
    for _, value in ipairs(mediaLang or {}) do
        if (value ~= nil) then
            genre_name_tmp = value .. ""
            table.insert(mtag, "语言/"..genre_name_tmp)
        end
    end
    for _, value in ipairs(mediaCountry or {}) do
        if (value ~= nil) then
            genre_name_tmp = value .. ""
            table.insert(mtag, "地区/"..genre_name_tmp)
        end
    end
    for _, value in ipairs(mediaCompany or {}) do
        if (value ~= nil) then
            genre_name_tmp = value .. ""
            table.insert(mtag, "出品方/"..genre_name_tmp)
        end
    end
    for _, value in ipairs(mediaNetwork or {}) do
        if (value ~= nil) then
            genre_name_tmp = value .. ""
            table.insert(mtag, "播映平台/"..genre_name_tmp)
        end
    end

    kiko.log("[INFO]  Finished getting " .. #mtag .. " tags of < " .. anime["name"] .. ">")
    return mtag
end

-- 实现自动关联功能。提供此函数的脚本会被加入到播放列表的“关联”菜单中)
-- path：视频文件全路径 -  path/to/video.ext
-- 返回：MatchResult
-- 读取 Emby 在媒体文件夹存储的 媒体信息文件 -  path/to/video.nfo
--     与媒体文件同目录同名的文本文档，文本格式为 .xml
function match(path)
    -- local err, fileHash = kiko.hashdata(path, true, 16*1024*1024)
    kiko.log('[INFO]  Matching path - <' .. path .. '> - ' .. #path)
    -- 获取 是否 元数据使用原语言标题
    local miotTmp = settings['metadata_info_origin_title']
    if (miotTmp == '0') then
        Metadata_info_origin_title = false
    elseif (miotTmp == '1') then
        Metadata_info_origin_title = true
    end

    local mediainfo, epinfo = {}, {} -- 返回的媒体信息、分集信息 AnimeLite:mediainfo EpInfo:epinfo
    --- 判断关联匹配的信息来源类型
    if settings["match_type"] == "online_TMDb_filename" then
        if (kiko.regex) == nil then
            kiko.message("错误! 版本过旧或不支持，请更换KikoPlay至合适的版本。",1|8)
            kiko.log("[Error] Using outdated or unsupported version!")
            kiko.execute(true, "cmd", {"/c", "start", "https://github.com/KikoPlayProject/KikoPlay#%E4%B8%8B%E8%BD%BD"})
            error("[Error] Using outdated or unsupported version!")
        end
        local mType = "" -- 媒体类型
        -- 模糊媒体信息：标题，季序数，集序数,集序数拓展,标题拓展,集类型
        local mTitle,mSeason,mEp,mEpX,mTitleX,mEpType = "","","","","",""
        local mPriority=1 -- x选取搜索结果
        local resultSearch,resultGetep = {},{} -- 影剧搜索结果、集识别
        local epTypeMap = {["EP"]=1, ["SP"]=2, ["OP"]=3, ["ED"]=4, ["TR"]=5, ["MA"]=6, ["OT"]=7,[""]=1} --仅针对特别篇的InfoRaw
        local epTypeName = {"正片", "特别篇", "片头", "片尾", "预告", "MAD", "其他片段"} --仅针对特别篇的Info展示

        --获取模糊媒体标题
        mTitle = string.gsub(path,"","")
        mType = ""

        -- 从文件名获取获取模糊媒体信息
        -- path: tv\season\video.ext | movie\video.ext
        local path_folder_sign, _ = string.findre(path, "/", -1) -- 路径索引 父文件夹尾'/' path/to[/]video.ext
        local path_file_name = string.sub(path, path_folder_sign + 1) -- 媒体文件名称.拓展名 - video.ext
        local resMirbf=Path.getMediaInfoRawByFilename(path_file_name)
        -- 获取 文件名粗识别 结果
        mTitle=resMirbf[1] or ""
        mSeason=resMirbf[2] or ""
        mEp=resMirbf[3] or ""
        mEpX=resMirbf[4] or ""
        mTitleX=resMirbf[5] or ""
        mEpType=resMirbf[6] or ""

        --判断媒体类型
        local mIsSp=false -- 是否为特别篇
        if mEpType~="" and mEpType~="EP" then
            mIsSp=true
        end
        if mEp~="" or mSeason~="" then
            mType="tv"
        -- 其他的，按照 设置项"匹配 - 备用媒体类型"。 -- 无集序数，无集类型
        elseif settings["match_priority"]=="movie" then
            mType="movie" -- 电影
        elseif settings["match_priority"]=="tv" then
            mType="tv" -- 剧集
        elseif settings["match_priority"]=="multi" then
            mType="multi" -- 排序靠前的影/剧
        elseif settings["match_priority"]=="single" then
            local resDiaTF, _ = kiko.dialog({
                ["title"] = "是否确定此媒体属于 <电影> ？",
                ["tip"] = "<" .. mTitle .. ">： 确认->电影。 取消->剧集。",
            })
            -- 从对话框确定媒体类型
            if resDiaTF == "accept" or resDiaTF == true then
                mType="movie"
            elseif resDiaTF == "reject" or resDiaTF == false then
                mType="tv"
                mIsSp=true
            else
                mType="multi"
            end
        else
            mType="multi"
        end

        if mType == "movie" then
            mSeason=1 -- 电影默认 S01E01 (EP)
            -- mediaInfo
            resultSearch = searchMediaInfo(mTitle,mType)
            if #resultSearch < mPriority then
                kiko.log("[ERROR] Failed to find movie <"..mTitle..">.")
                kiko.message("无法找到电影 <"..mTitle..">。", 1)
                return {["success"] = true, ["anime"] = {["name"]=mTitle}, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
            end
            mediainfo=resultSearch[mPriority]
            
            -- epInfo
            if mIsSp == false then
                local mEpTmp=1
                resultGetep = getep(mediainfo)
                if #resultGetep < mEpTmp then
                    kiko.log("[ERROR] Failed to find movie <"..mTitle..">。")
                    kiko.message("无法找到电影 <"..mTitle..">。", 1)
                    return {["success"] = true, ["anime"] = {["name"]=mTitle}, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
                end
                epinfo=resultGetep[mEpTmp]
            else
                epinfo={
                    ["name"] = mTitleX,
                    ["index"] = ((mEp == "")and{nil}or{ math.floor(tonumber(mEp)) })[1],
                    ["type"] = ((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType]})[1],
                }
                if epinfo["index"] == nil then
                    kiko.log("[ERROR] Failed to find movie <"..mTitle.."> " .. ": " .. epTypeName[epinfo["type"]] ..
                                (((mEp=="")and{""}or{string.format(" %02d",mEp)})[1])..
                                (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。")
                    kiko.message("无法找到电影 <"..mTitle.."> " .. "的 " .. epTypeName[epinfo["type"]] ..
                                (((mEp=="")and{""}or{string.format(" %02d",mEp)})[1])..
                                (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。", 1)
                    return {["success"] = true, ["anime"] = mediainfo, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
                end
            end
        elseif mType == "tv" then
            -- Season=="" -> S00/S01。
            local mSeasonTv = ""
            if mSeason == "" then
                mSeasonTv = ((mIsSp)and{0}or{1})[1]
            else mSeasonTv = math.floor(tonumber(mSeason))
            end
            -- mediaInfo
            resultSearch = searchMediaInfo(mTitle,mType)
            for _, value in ipairs(resultSearch or {}) do
                if mSeasonTv ~= 0 then
                    if value["season_number"] == mSeasonTv or tostring(value["season_number"]) == tostring(mSeasonTv) then
                        mediainfo=value
                        mType=mediainfo["media_type"]
                        break
                    end
                else
                    -- Specials
                    if value["season_number"] == mSeasonTv or tostring(value["season_number"]) == tostring(mSeasonTv) or
                        value["season_number"] == 1 or tostring(value["season_number"]) == tostring(1) then
                        mediainfo=value
                        mType=mediainfo["media_type"]
                        break
                    end
                end
            end
            if table.isEmpty(mediainfo) then
                kiko.log("[ERROR] Failed to find tv <"..mTitle.."> ".. (((mSeason=="")and{""}or{" < Season"..mSeason.." >"})[1]).."。")
                kiko.message("无法找到剧集 <"..mTitle.."> ".. (((mSeason=="")and{""}or{"的 <第"..mSeason.."季>"})[1]).."。", 1)
                return {["success"] = true, ["anime"] = {["name"]=mTitle}, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
            end

            -- EpX：提示，并弃用
            if mEpX ~= "" then
                mEpX=math.floor(tonumber(mEpX))
                kiko.log("[INFO]  Recognized redundant episode number <"..(mEpX or "").."> in tv <"..(mTitle or "")..">, which is ignored here.")
                kiko.message("识别到 <"..((mTitle.."> 的") or "").."拓展集序号: <"..(mEpX or "")..">。\n" ..
                            "此处弃用，请稍后确认此剧集的集序号是否正确", 1)
            end
            -- epInfo
            local mEpTmp = nil
            if mEp == "" then
                mEpTmp=1
            else mEpTmp=math.floor(tonumber(mEp))
            end
            if mIsSp == false then
                resultGetep = getep(mediainfo)
                for _, value in ipairs(resultGetep or {}) do
                    if value["index"] == mEpTmp or tostring(value["index"]) == tostring(mEpTmp) then
                        epinfo=value
                        break
                    end
                end
                if table.isEmpty(epinfo) then
                    kiko.log("[ERROR] Failed to find tv <"..mTitle..(((mSeason=="")and{""}or{" Season"..mSeason})[1])..">" ..
                                (((mEp=="")and{""}or{" <Episode "..mEp..">"})[1]).."。")
                    kiko.message("无法找到剧集 <"..mTitle..(((mSeason=="")and{""}or{" 第"..mSeason.."季"})[1])..">" ..
                                (((mEp=="")and{""}or{"的 <第"..mEp.."集>"})[1]).."。", 1)
                    return {["success"] = true, ["anime"] = mediainfo, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"] = math.floor(tonumber(mEpTmp)),["type"]=1,},}
                end
            else
                epinfo={
                    ["name"] = mTitleX,
                    ["index"] = ((mEp == "")and{nil}or{ math.floor(tonumber(mEp)) })[1],
                    ["type"] = ((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType]})[1],
                }
                if epinfo["index"] == nil then
                    kiko.log("[ERROR] Failed to find  <"..mTitle..(((mSeason=="")and{""}or{" Season "..mSeason})[1]).."> "..
                            " in " .. epTypeName[epinfo["type"]] .. (((mEp=="")and{""}or{string.format(" %02d",mEp)})[1])..
                            (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。")
                    kiko.message("无法找到剧集 <"..mTitle..(((mSeason=="")and{""}or{" 第"..mSeason.."季"})[1]).."> "..
                            "的 " .. epTypeName[epinfo["type"]] .. (((mEp=="")and{""}or{string.format("%02d",mEp)})[1])..
                            (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。", 1)
                    -- kiko.log("[TEST]  "..type(os.time2EpiodeNum()).." - "..os.time2EpiodeNum())
                    return {["success"] = true, ["anime"] = mediainfo,
                            ["ep"] = {["name"]= (string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1] ,
                                    ["index"]=os.time2EpiodeNum(),
                                    ["type"]=math.floor(((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType] or 7})[1])},}
                end
            end
        else
            -- mediaInfo
            resultSearch = searchMediaInfo(mTitle,"multi")
            if #resultSearch < mPriority then
                kiko.log("[ERROR] Failed to find media <"..mTitle..">。")
                kiko.message("无法找到媒体 <"..mTitle..">。", 1)
                return {["success"] = true, ["anime"] = {["name"]=mTitle}, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
            end
            local mSeasonTv = ""
            for _, value in ipairs(resultSearch or {}) do
                if mSeason =="" and value["media_type"] == "movie" then
                    if mIsSp == false and mEp ~= "" then
                        goto continue_match_OMul_Mnfo
                    end
                    mSeason=1
                    mediainfo=value
                    mType=mediainfo["media_type"]
                    break
                elseif value["media_type"]=="tv" then
                    if mSeason == "" then
                        mSeasonTv = ((mIsSp)and{0}or{1})[1]
                    else mSeasonTv = math.floor(tonumber(mSeason))
                    end
                    if mSeasonTv ~= 0 then
                        if value["season_number"] == mSeasonTv or tostring(value["season_number"]) == tostring(mSeasonTv) then
                            mediainfo=value
                            mType=mediainfo["media_type"]
                            break
                        else goto continue_match_OMul_Mnfo
                        end
                    else
                        -- Specials
                        if value["season_number"] == mSeasonTv or tostring(value["season_number"]) == tostring(mSeasonTv) or
                            value["season_number"] == 1 or tostring(value["season_number"]) == tostring(1) then
                            mediainfo=value
                            mType=mediainfo["media_type"]
                            break
                        else goto continue_match_OMul_Mnfo
                        end
                    end
                end
                ::continue_match_OMul_Mnfo::
            end
            if table.isEmpty(mediainfo) then
                if mSeason ~="" or (mEp ~= "" and mIsSp ==false)  then
                    kiko.log("[ERROR] Failed to find tv <"..mTitle.."> ".. (((mSeason=="")and{""}or{"的 <Season "..mSeason..">"})[1]).."。")
                    kiko.message("无法找到剧集 <"..mTitle.."> ".. (((mSeason=="")and{""}or{"的 <第"..mSeason.."季>"})[1]).."。", 1)
                else
                    kiko.log("[ERROR] Failed to find media <"..mTitle..">。")
                    kiko.message("无法找到媒体 <"..mTitle..">。", 1)
                end
                return {["success"] = true, ["anime"] = {["name"]=mTitle}, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"] = math.floor(tonumber(mEp)) or os.time2EpiodeNum()},["type"]=7,}
            end

            -- mEpX=math.floor(tonumber(mEpX))
            if mEpX ~= "" then
                kiko.log("Recognized redundant episode number <"..(mEpX or "").."> of"..(mTitle or "")..", which is ignored here.")
                kiko.message("识别到 <"..((mTitle.."> 的") or "").."拓展集序号: <"..(mEpX or "")..">。\n" ..
                            "此处弃用，请稍后确认此剧集的集序号是否正确", 1)
            end
            -- epInfo
            if mIsSp == false then
                if mType == "tv" then
                    local mEpTmp = nil
                    if mEp == "" then
                        mEpTmp=1
                    else mEpTmp=math.floor(tonumber(mEp))
                    end
                    resultGetep = getep(mediainfo)
                    for _, value in ipairs(resultGetep or {}) do
                        if value["index"] == mEpTmp or tostring(value["index"]) == tostring(mEpTmp) then
                            epinfo=value
                            break
                        end
                    end
                    if table.isEmpty(epinfo) then
                        kiko.log("[ERROR] Failed to find tv <"..mTitle..(((mSeason=="")and{""}or{" Season "..mSeason})[1])..">" ..
                                    (((mEp=="")and{""}or{" <Episode"..mEp..">"})[1]).."。")
                        kiko.message("无法找到剧集 <"..mTitle..(((mSeason=="")and{""}or{" 第"..mSeason.."季"})[1])..">" ..
                                    (((mEp=="")and{""}or{"的 <第"..mEp.."集>"})[1]).."。", 1)
                        return {["success"] = true, ["anime"] = mediainfo, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
                    end
                elseif mType == "movie" then
                    mEp=1
                    resultGetep = getep(mediainfo)
                    if #resultGetep < mEp then
                        kiko.log("[ERROR] Failed to find movie <"..mTitle..">。")
                        kiko.message("无法找到电影 <"..mTitle..">。", 1)
                        return {["success"] = true, ["anime"] = mediainfo, ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1],["index"]=os.time2EpiodeNum(),["type"]=7,},}
                    end
                    epinfo=resultGetep[mEp]
                end
            else
                epinfo={
                    ["name"] = mTitleX,
                    ["index"] = ((mEp == "")and{nil}or{ math.floor(tonumber(mEp)) })[1],
                    ["type"] = ((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType]})[1],
                }
                if epinfo["index"] == nil then
                    local tmpLogStr = "的 " .. epTypeName[epinfo["type"]] .. (((mEp=="")and{""}or{string.format("%02d",mEp)})[1])..
                                        (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。"
                    if epinfo["type"] == "movie" then
                        kiko.log("[ERROR] Failed to find movie <"..mTitle.."> " .. tmpLogStr)
                        kiko.message("无法找到电影 <"..mTitle.."> " .. tmpLogStr, 1)
                    elseif epinfo["type"] == "tv" then
                        kiko.log("[ERROR] Failed to find tv <"..mTitle..(((mSeason=="")and{""}or{" Season "..mSeason})[1]).."> ".. tmpLogStr)
                        kiko.message("无法找到剧集 <"..mTitle..(((mSeason=="")and{""}or{" 第"..mSeason.."季"})[1]).."> ".. tmpLogStr, 1)
                    else
                        kiko.log("[ERROR] Failed to find media <"..mTitle.."> " .. tmpLogStr)
                        kiko.message("无法找到媒体 <"..mTitle.."> " .. tmpLogStr, 1)
                    end
                    return {["success"] = true, ["anime"] = mediainfo,
                            ["ep"] = {["name"]=(string.isEmpty(mTitleX) and{mTitle}or{mTitleX})[1], ["index"]=os.time2EpiodeNum(),["type"]=math.floor(((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType]})[1])},}
                end
            end
        end

        kiko.log("(" .. (mType or "") .. ") " .. (mediainfo["name"] or "") .. "  -  " ..
                 "(" .. (epTypeName[epinfo["type"]] or "") .. ") " .. (epinfo["index"] or "") .. (epinfo["name"] or ""))
        kiko.log("Finished matching online succeeded.")

        return {
            ["success"] = true,
            ["anime"] = mediainfo,
            ["ep"] = epinfo,
        }
    elseif settings["match_type"] == "local_Emby_nfo" then

        -- 获取需要的各级目录
        -- string.gmatch(path,"\\[%S ^\\]+",-1)
        -- path: tv\season\video.ext  lff\lf\l  Emby 存储剧集的目录 -  tv/tvshow.nfo  tv/season/season.nfo
        -- path: movie\video.ext	  l\        Emby 存储电影的目录 -  movie/video.nfo
        local path_file_sign, _ = string.findre(path, ".", -1) -- 路径索引 文件拓展名前'.' path/to/video[.]ext
        local path_folder_sign, _ = string.findre(path, "/", -1) -- 路径索引 父文件夹尾'/' path/to[/]video.ext
        -- kiko.log('TEST  - '..path_file_sign)
        -- kiko.log('TEST  - '..path_folder_sign)
        local path_file_name = string.sub(path, path_folder_sign + 1,
                                        path_file_sign - 1) -- 媒体文件名称 不含拓展名 - video
        local path_folder_l = string.sub(path, 1, path_folder_sign) -- 父文件夹路径 含结尾'/' -  tv/season/   movie/
        path_folder_sign, _ = string.findre(path, "/", path_folder_sign - 1) -- 路径索引 父父文件夹尾'/' path[/]to/video.ext
        local path_folder_lf = string.sub(path, 1, path_folder_sign) -- 父父文件夹路径 含结尾'/' -  tv/

        -- 读取媒体信息.nfo文件 (.xml文本)
        local xml_file_path = path_folder_l .. path_file_name .. '.nfo' -- 媒体信息文档全路径 path/to/video.nfo 文本为 .xml 格式
        local xml_v_nfo = Path.readxmlfile(xml_file_path) -- 获取媒体信息文档
        if xml_v_nfo == nil then
            -- 文件读取失败
            kiko.log("[ERROR] Fail to read xml content from <" .. xml_file_path .. ' >.')
            error("Fail to read xml content from <" .. xml_file_path .. ' >.')
            -- kiko.log("[Error]\tFail to read xml content from <".. xml_file_path .. ' >.')
            -- 返回
            return {["success"] = false};
        end

        -- xml_v_nfo
        -- 读取的媒体信息文本暂存在这里
        -- local mname, mdata, murl, mdesc, mairdate, mepcount, mcoverurl, mstaff, mcrt = nil, {}, nil, nil, nil, nil, nil,
        local mname, mdata, mepcount = nil, {}, nil
        local myear = nil
        -- 读取的分集信息文本暂存在这里
        local ename, eindex, etype, eseason = nil, nil, nil, nil
        -- 读取的分季信息文本暂存在这里
        -- tstitle = season title
        local tstitle = nil
        -- 读取的 .xml 信息文本暂存在这里
        local tmpElem -- 临时存 xml_v_nfo:elemtext()
        while not xml_v_nfo:atend() do
            -- 循环，直到读取到末尾
            if xml_v_nfo:startelem() then
                -- 如果是开始标签，就获取 媒体类型信息，分类电影/剧集
                -- movie
                if xml_v_nfo:name() == "movie" then
                    -- 是电影
                    kiko.log('[INFO]  \t Reading movie nfo')
                    mdata["media_type"] = "movie" -- 媒体类型
                    mdata["poster_path"] = "" .. path_folder_l .. "poster.jpg" -- Emby存储的电影 海报路径
                    mdata["background_path"] = "" .. path_folder_l .. "fanart.jpg" -- Emby存储的电影 背景路径
                    kiko.log('[INFO]  Reading movie nfo')

                    -- 读取下一个标签
                    xml_v_nfo:readnext()
                    while not xml_v_nfo:atend() do
                        -- 循环，直到读取到末尾
                        if xml_v_nfo:startelem() then
                            -- 如果是开始标签，就获取信息
                            -- read metadata
                            if xml_v_nfo:name() ~= "actor" then
                                -- 如果不是"演员"标签，读取标签内容
                                tmpElem = xml_v_nfo:elemtext() .. ""
                            else
                                -- 如果是"演员"标签，之后循环单独读取演员标签组内容到<table>
                                tmpElem = ""
                            end
                            if xml_v_nfo:name() == "title" then
                                -- "标题"标签
                                mdata["media_title"] = tmpElem
                                -- if not (Metadata_info_origin_title) then
                                --     mname = mdata["media_title"]
                                -- end
                            elseif xml_v_nfo:name() == "originaltitle" then
                                -- "原始标题"标签
                                mdata["original_title"] = tmpElem
                                -- if Metadata_info_origin_title then
                                --     mname = mdata["original_title"]
                                -- end
                            elseif xml_v_nfo:name() == "plot" then
                                -- "剧情简介"标签
                                -- mdesc = tmpElem
                                mdata["overview"] = string.gsub(tmpElem, "\r?\n\r?\n", "\n") -- 去除空行
                            elseif xml_v_nfo:name() == "director" then
                                -- "导演"标签
                                if mdata["person_crew"] == nil then
                                    mdata["person_crew"] = ''
                                end
                                -- 处理职员表字符串信息
                                if not string.isEmpty(tmpElem) then
                                    table.insert(mdata["person_crew"],{
                                        ["name"]= tmpElem or"",
                                        ["original_name"]= tmpElem or"",
                                        ["department"]= "Directing",
                                        ["job"]= "Director",
                                    })
                                end
                            elseif xml_v_nfo:name() == "rating" then
                                -- "评分"标签
                                mdata["vote_average"] = tmpElem
                            elseif xml_v_nfo:name() == "year" then
                                -- "播映年份"标签
                                if tmpElem ~= nil and tmpElem ~= "" then
                                    -- 无标签内容
                                    myear = tmpElem
                                elseif mdata["release_date"] ~= nil and mdata["release_date"] ~= "" then
                                    -- 读取首映/发行日期的年份
                                    myear = string.sub(mdata["release_date"], 1, 4)
                                end
                                -- elseif xml_v_nfo:name()=="content" then
                                -- mcoverurl = tmpElem
                                -- elseif xml_v_nfo:name() == "sorttitle" then
                                --     mdata["sort_title"] = tmpElem
                            elseif xml_v_nfo:name() == "mpaa" then
                                -- "媒体分级/mpaa"标签
                                mdata["rate_mpaa"] = tmpElem
                            elseif xml_v_nfo:name() == "tmdbid" then
                                -- "tmdb的ID"标签
                                mdata["media_id"] = string.format("%d", tmpElem)
                                -- if mdata["media_id"] ~= nil then
                                --     mdata[""] = "https://www.themoviedb.org/movie/" .. mdata["media_id"]
                                -- end
                            elseif xml_v_nfo:name() == "imdbid" then
                                -- "imdb的id"标签
                                mdata["media_imdbid"] = tmpElem
                            elseif xml_v_nfo:name() == "premiered" then -- 首映
                                -- "首映日期"标签
                                local elemtext_tmp = tmpElem
                                if elemtext_tmp ~= nil and elemtext_tmp ~= "" and mdata["release_date"] == nil then
                                    mdata["release_date"] = string.sub(elemtext_tmp, 1, 10)
                                end
                            elseif xml_v_nfo:name() == "releasedate" then -- 发行
                                -- "发行日期"标签
                                local elemtext_tmp = tmpElem
                                if elemtext_tmp ~= nil and elemtext_tmp ~= "" and mdata["release_date"] == nil then
                                    mdata["release_date"] = string.sub(elemtext_tmp, 1, 10)
                                end
                            elseif xml_v_nfo:name() == "country" then
                                -- "国家"标签
                                if mdata["origin_country"] == nil then
                                    mdata["origin_country"] = {}
                                end
                                table.insert(mdata["origin_country"], tmpElem)
                            elseif xml_v_nfo:name() == "genre" then
                                -- "流派类型-名称"标签
                                if mdata["genre_names"] == nil then
                                    mdata["genre_names"] = {}
                                end
                                table.insert(mdata["genre_names"], tmpElem)
                            elseif xml_v_nfo:name() == "studio" then
                                -- "出品 公司/工作室"标签
                                if mdata["production_company"] == nil then
                                    mdata["production_company"] = {}
                                end
                                table.insert(mdata["production_company"], tmpElem)
                            elseif xml_v_nfo:name() == "actor" then
                                -- "演员"标签组
                                if mdata["person_cast"] == nil then
                                    -- 初始化table
                                    mdata["person_cast"] = {}
                                end
                                -- 初始化演员信息文本暂存
                                local cname, cactor, clink, cimgurl = nil, nil, nil, nil
                                -- 读取下一个标签
                                xml_v_nfo:readnext()
                                -- read actors in .nfo
                                while xml_v_nfo:name() ~= "actor" or not (not xml_v_nfo:startelem()) do
                                    -- 循环，直到读取到"演员"的结束标签
                                    if xml_v_nfo:startelem() then
                                        -- 是开始标签
                                        -- 读取标签内容文本
                                        tmpElem = xml_v_nfo:elemtext() .. ""
                                        if xml_v_nfo:name() == "role" then
                                            -- "角色名"标签
                                            cname = tmpElem
                                        elseif xml_v_nfo:name() == "name" then
                                            -- "演员名"标签
                                            cactor = tmpElem
                                        elseif xml_v_nfo:name() == "tmdbid" then
                                            -- "tmdb的演员id"标签 -> tmdb演员页链接
                                            clink = "https://www.themoviedb.org/person/" .. tmpElem
                                            -- elseif xml_v_nfo:name()=="content" then
                                            --     cimgurl = tmpElem
                                        end
                                        -- kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>.'..tmpElem)
                                    end
                                    -- 读取下一个标签
                                    xml_v_nfo:readnext()
                                end
                                --[[
							xml_v_nfo_crt=kiko.xmlreader(tmpElem)
							kiko.log('TEST  - Actor Tag: ')
							cname, cactor, clink, cimgurl=nil, nil, nil, nil
							while not xml_v_nfo_crt:atend() do
								if xml_v_nfo_crt:startelem() then
									if xml_v_nfo_crt:name()=="role" then
										cname = xml_v_nfo_crt:elemtext()
									elseif xml_v_nfo_crt:name()=="name" then
										cactor = xml_v_nfo_crt:elemtext()
									-- elseif xml_v_nfo_crt:name()=="content" then
										-- clink = xml_v_nfo_crt:elemtext()
									-- elseif xml_v_nfo_crt:name()=="content" then
										-- cimgurl = xml_v_nfo_crt:elemtext()
									end
									kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>.')
								end
								xml_v_nfo:readnext()
							end
							]] --
                                -- 向演员信息<table>插入一个演员的信息
                                table.insert(mdata["person_cast"], {
                                    ["name"] = cname, -- 人物名称
                                    ["name"] = cactor, -- 演员名称
                                    ["url"] = clink -- 人物资料页URL
                                    -- ["imgurl"]=cimgurl,  --人物图片URL
                                })
                                -- xml_v_nfo_crt=nil
                            end
                            -- kiko.log('[INFO]  Reading tag <' .. xml_v_nfo:name() .. '>' .. tmpElem)
                        end
                        -- 读取下一个标签
                        xml_v_nfo:readnext()
                    end
                    -- xml_v_nfo:clear()

                    -- 把电影视为单集电视剧，初始化单集信息，
                    mepcount, ename, eindex, etype = 1, "", 1, 1

                    -- 获取电影标题，是否原语言标题
                    if Metadata_info_origin_title then
                        mname = mdata["original_title"]
                        -- kiko.log("T " .. mname)
                    else
                        mname = mdata["media_title"]
                        -- kiko.log("F " .. mname)
                    end
                    -- kiko.log("OOO " .. mname .. "\t" .. tostring(Metadata_info_origin_title))
                    -- 单集标题
                    ename = mdata["media_title"]

                    -- 把媒体信息<table>转为json的字符串
                    local err, movie_data_json = kiko.table2json(table.deepCopy(mdata))
                    if err ~= nil then
                        -- 转换错误
                        kiko.log(string.format("[ERROR] table2json: %s", err))
                    end
                    -- 媒体信息表
                    mediainfo = {
                        ["name"] = mname, -- 电影标题
                        ["data"] = movie_data_json, -- 脚本可以自行存放一些数据，table转为json的字符串
                        -- ["url"] = murl, -- 条目页面再tmdb的URL
                        -- ["desc"] = mdesc, -- 剧集剧情描述
                        -- ["airdate"] = mairdate, -- 发行日期，格式为yyyy-mm-dd
                        ["epcount"] = mepcount -- 分集数
                        -- ["coverurl"]=mcoverurl,      --封面图URL
                        -- ["staff"] = mstaff, -- 职员表，格式的字符串
                        -- ["crt"] = mcrt -- 人物/演员表 <table>
                    }
                    -- 从 媒体信息的发行日期/年份 获取年份字符串，加到电影名后，以防重名导致kiko数据库错误。形如 "电影名 (2010)"
                    -- get "Movie Name (YEAR)"
                    if mdata["release_date"] ~= nil and mdata["release_date"] ~= "" then
                        mediainfo["name"] = mname .. string.format(' (%s)', string.sub(mdata["release_date"], 1, 4))
                    elseif myear ~= nil and myear ~= "" then
                        mediainfo["name"] = mname .. string.format(' (%s)', myear)
                    end
                    -- 单集信息表
                    epinfo = {
                        ["name"] = ename, -- 分集名称
                        ["index"] = eindex, -- 分集编号（索引）
                        ["type"] = etype -- 分集类型
                    }
                    -- 跳出标签读取循环
                    break

                    -- tv_show
                elseif xml_v_nfo:name() == "episodedetails" then
                    -- 是剧集
                    mdata["media_type"] = "tv" -- 媒体类型
                    kiko.log('[INFO]  \t Reading tv episode nfo')

                    -- xml_v_nfo:startelem()
                    -- 读取下一个标签
                    xml_v_nfo:readnext()
                    -- read metadata
                    while not xml_v_nfo:atend() do
                        -- 循环，直到读取到末尾
                        if xml_v_nfo:startelem() then
                            -- 如果是开始标签，就获取信息
                            if xml_v_nfo:name() ~= "actor" then
                                -- 如果不是"演员"标签，读取标签内容
                                tmpElem = xml_v_nfo:elemtext() .. ""
                            else
                                -- 如果是"演员"标签，之后循环单独读取演员标签组内容到<table>
                                tmpElem = ""
                            end
                            -- kiko.log("GE "..xml_v_nfo:name().."\t"..tmpElem)
                            if xml_v_nfo:name() == "title" then
                                -- "单集标题"标签
                                ename = tmpElem
                            elseif xml_v_nfo:name() == "episode" then
                                -- "本集序数"标签
                                eindex = tonumber(tmpElem)
                            elseif xml_v_nfo:name() == "season" then
                                -- "本季序数"标签
                                if (tmpElem ~= nil and tmpElem ~= '') then
                                    mdata["season_number"] = tonumber(tmpElem) -- 本季序数转为数字
                                    -- S00 == Specials
                                    -- 分集类型: EP, SP, OP, ED, Trailer, MAD, Other 分别用1-7表示，默认为1（即EP，本篇）
                                    if mdata["season_number"] == 0 then
                                        -- 0季/特别篇/SP
                                        etype = 2
                                    else
                                        -- 普通集/本篇/EP
                                        etype = 1
                                    end
                                end

                            elseif xml_v_nfo:name() == "director" then
                                -- "导演"标签
                                if mdata["person_crew"] == nil then
                                    mdata["person_crew"] = ''
                                end
                                -- 处理职员表字符串信息
                                if not string.isEmpty(tmpElem) then
                                    table.insert(mdata["person_crew"],{
                                        ["name"]= tmpElem or"",
                                        ["original_name"]= tmpElem or"",
                                        ["department"]= "Directing",
                                        ["job"]= "Director",
                                    })
                                end
                            elseif xml_v_nfo:name() == "actor" then
                                -- xml_v_nfo:readnext()
                                -- ignore actors
                                -- while xml_v_nfo:name() ~= "actor" or not (not xml_v_nfo:startelem()) do
                                --     -- kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>'..tmpElem)
                                --     xml_v_nfo:readnext()

                                -- "演员"标签组
                                if mdata["person_cast"] == nil then
                                    mdata["person_cast"] = {}
                                end
                                -- kiko.log("TEST  - Actor tag"..tmpElem)
                                -- 初始化演员信息文本暂存
                                local cname, cactor, clink, cimgurl = nil, nil, nil, nil
                                -- 读取下一个标签
                                xml_v_nfo:readnext()
                                -- read actors in .nfo
                                while xml_v_nfo:name() ~= "actor" or not (not xml_v_nfo:startelem()) do
                                    -- 循环，直到读取到"演员"的结束标签
                                    if xml_v_nfo:startelem() then
                                        -- 是开始标签
                                        -- 读取标签内容文本
                                        tmpElem = xml_v_nfo:elemtext() .. ""
                                        if xml_v_nfo:name() == "role" then
                                            -- "角色名"标签
                                            cname = tmpElem
                                        elseif xml_v_nfo:name() == "name" then
                                            -- "演员名"标签
                                            cactor = tmpElem
                                        elseif xml_v_nfo:name() == "tmdbId" then
                                            -- "tmdb的演员id"标签 -> tmdb演员页链接
                                            -- clink = "https://www.themoviedb.org/person/" .. tmpElem
                                            clink = tmpElem
                                            -- elseif xml_v_nfo:name()=="content" then
                                            --     cimgurl = tmpElem
                                        end
                                        -- kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>.'..tmpElem)
                                    end
                                    -- 读取下一个标签
                                    xml_v_nfo:readnext()
                                end
                                -- 向演员信息<table>插入一个演员的信息
                                table.insert(mdata["person_cast"], {
                                    ["name"] = cname, -- 人物名称
                                    ["original_name"] = cname, -- 人物名称
                                    ["character"] = cactor, -- 演员名称
                                    ["department"]= "Actors",
                                    ["job"]="Actor",
                                    ["id"] = tonumber(clink or""),
                                })
                                -- kiko.log(table.toStringLine(mdata["person_cast"]))
                            end
                            -- kiko.log('[INFO]  Reading tag <' .. xml_v_nfo:name() .. '>' .. tmpElem)
                        end
                        -- 读取下一个标签
                        xml_v_nfo:readnext()
                    end
                    -- xml_v_nfo:clear()

                    kiko.log('[INFO]  \t Reading tv season nfo')
                    -- 读取单季信息.nfo文件 (.xml文本)
                    local xml_ts_path = path_folder_l .. 'season.nfo' -- 单季信息.nfo文件路径
                    local xml_ts_nfo = Path.readxmlfile(xml_ts_path) -- 读取.xml格式文本
                    if xml_ts_nfo == nil then
                        -- 文件读取失败
                        kiko.log("[ERROR] Fail to read xml content from <" .. xml_file_path .. ' >.')
                        error("Fail to read xml content from <" .. xml_file_path .. ' >.')
                        -- kiko.log("[Error]\tFail to read xml content from <".. xml_file_path .. ' >.')
                        return {["success"] = false};
                    end
                    while (xml_ts_nfo:endelem()) or xml_ts_nfo:name() ~= "season" do
                        xml_ts_nfo:readnext()
                    end
                    -- read metadata
                    xml_ts_nfo:readnext()
                    while not xml_ts_nfo:atend() do
                        -- 循环，直到读取到末尾
                        if xml_ts_nfo:startelem() then
                            -- 如果是开始标签，就获取信息
                            if xml_ts_nfo:name() ~= "actor" then
                                -- 如果不是"演员"标签，读取标签内容
                                tmpElem = xml_ts_nfo:elemtext() .. ""
                            else
                                -- 如果是"演员"标签，之后循环单独读取演员标签组内容到<table>
                                tmpElem = ""
                            end
                            if xml_ts_nfo:name() == "title" then
                                -- "标题"标签
                                tstitle = tmpElem
                            elseif xml_ts_nfo:name() == "plot" then
                                -- "剧情简介"标签
                                mdata["overview"] = string.gsub(tmpElem, "\r?\n\r?\n", "\n") -- 去除空行
                            elseif xml_ts_nfo:name() == "premiered" then
                                -- "首播日期"标签
                                local elemtext_tmp = tmpElem
                                if elemtext_tmp ~= nil then
                                    mdata["release_date"] = string.sub(elemtext_tmp, 1, 10)
                                end
                                if (myear == nil or myear == "") and mdata["release_date"] ~= nil and
                                    mdata["release_date"] ~="" then
                                    myear = string.sub(mdata["release_date"], 1, 4)
                                end
                            elseif xml_ts_nfo:name() == "releasedate" then
                                -- "发行日期"标签
                                local elemtext_tmp = tmpElem
                                if (mdata["release_date"] == nil or mdata["release_date"] == "") and elemtext_tmp ~= nil then
                                    mdata["release_date"] = string.sub(elemtext_tmp, 1, 10)
                                end
                                -- 获取年份
                                if (myear == nil or myear == "") and mdata["release_date"] ~= nil and mdata["release_date"] ~="" then
                                    myear = string.sub(mdata["release_date"], 1, 4)
                                end
                            elseif xml_ts_nfo:name() == "seasonnumber" then
                                -- "本季序数"标签
                                if (mdata["season_number"] == nil and tmpElem ~= nil and tmpElem ~= '') then
                                    mdata["season_number"] = tonumber(tmpElem)
                                    if mdata["season_number"] == 0 then
                                        -- 0季/特别篇/SP
                                        etype = 2
                                    else
                                        -- 普通集/本篇/EP
                                        etype = 1
                                    end
                                end
                                -- elseif xml_ts_nfo:name()=="content" then
                                -- mepcount = tmpElem

                            elseif xml_ts_nfo:name() == "actor" then
                                -- "演员"标签组
                                if mdata["person_cast"] == nil then
                                    mdata["person_cast"] = {}
                                end
                                -- 初始化演员信息文本暂存
                                local cname, cactor, clink, cimgurl = nil, nil, nil, nil
                                xml_ts_nfo:readnext()
                                -- read actors in .nfo
                                while xml_ts_nfo:name() ~= "actor" or not (not xml_ts_nfo:startelem()) do
                                    -- 循环，直到读取到"演员"的结束标签
                                    if xml_ts_nfo:startelem() then
                                        -- 是开始标签
                                        -- 读取标签内容文本
                                        tmpElem = xml_ts_nfo:elemtext() .. ""
                                        if xml_ts_nfo:name() == "role" then
                                            -- "角色名"标签
                                            cname = tmpElem
                                        elseif xml_ts_nfo:name() == "name" then
                                            -- "演员名"标签
                                            cactor = tmpElem
                                        elseif xml_ts_nfo:name() == "tmdbId" then
                                            -- "tmdb的演员id"标签 -> tmdb演员页链接
                                            clink = "https://www.themoviedb.org/person/" .. tmpElem
                                            -- elseif xml_ts_nfo:name()=="content" then
                                            --     cimgurl = tmpElem
                                        end
                                        -- kiko.log('TEST  - Actor tag <'..xml_ts_nfo:name()..'>.'..tmpElem)
                                    end
                                    -- 读取下一个标签
                                    xml_ts_nfo:readnext()
                                end
                                -- 未去重
                                table.insert(mdata["person_cast"], {
                                    ["name"] = cname, -- 人物名称
                                    ["original_name"] = cname, -- 人物名称
                                    ["character"] = cactor, -- 演员名称
                                    ["department"]= "Actors",
                                    ["job"]="Actor",
                                    ["id"] = tonumber(clink or""),
                                })
                                -- kiko.log(table.toStringLine(mdata["person_cast"]))
                            end
                            -- kiko.log('[INFO]  Reading tag <' .. xml_ts_nfo:name() .. '>' .. tmpElem)
                        end
                        -- 读取下一个标签
                        xml_ts_nfo:readnext()
                    end
                    xml_ts_nfo:clear()

                    kiko.log('[INFO]  \t Reading tv nfo')
                    local xml_tv_path = path_folder_lf .. 'tvshow.nfo' -- 单季信息.nfo文件路径
                    local xml_tv_nfo = Path.readxmlfile(xml_tv_path) -- 读取.xml格式文本
                    if xml_tv_nfo == nil then
                        -- 文件读取失败
                        kiko.log("[ERROR] Fail to read xml content from <" .. xml_file_path .. ' >.')
                        error("Fail to read xml content from <" .. xml_file_path .. ' >.')
                        -- kiko.log("[Error]\tFail to read xml content from <".. xml_file_path .. ' >.')
                        return {["success"] = false};
                    end
                    while (xml_tv_nfo:endelem()) or xml_tv_nfo:name() ~= "tvshow" do
                        xml_tv_nfo:readnext()
                        end
                    -- read metadata
                    xml_tv_nfo:readnext()
                    while not xml_tv_nfo:atend() do
                        -- 循环，直到读取到末尾
                        if xml_tv_nfo:startelem() then
                            -- 如果是开始标签，就获取信息
                            if xml_tv_nfo:name() ~= "actor" then
                                -- 如果不是"演员"标签，读取标签内容
                                tmpElem = xml_tv_nfo:elemtext() .. ""
                            else
                                -- 如果是"演员"标签，之后循环单独读取演员标签组内容到<table>
                                tmpElem = ""
                            end
                            if xml_tv_nfo:name() == "title" then
                                -- "标题"标签
                                mdata["media_title"] = tmpElem
                                -- if not (Metadata_info_origin_title) then
                                --     mname = mdata["media_title"]
                                -- end
                            elseif xml_tv_nfo:name() == "originaltitle" then
                                -- "原语言标题"标签
                                mdata["original_title"] = tmpElem
                                -- if Metadata_info_origin_title then
                                --     mname = mdata["original_title"]
                                -- end
                            elseif xml_tv_nfo:name() == "plot" then
                                -- "剧情简介"标签
                                -- mdesc = tmpElem
                                if mdata["overview"] ~= nil then
                                mdata["overview"] = string.gsub(mdata["overview"], "\r?\n\r?\n", "\n") .. "\r\n" -- 去除空行
                                else
                                    mdata["overview"] = ""
                                end
                            mdata["overview"] = mdata["overview"] .. string.gsub(tmpElem, "\r?\n\r?\n", "\n")
                                -- elseif xml_tv_nfo:name()=="content" then
                                -- mcoverurl = tmpElem
                            elseif xml_tv_nfo:name() == "rating" then
                                -- "评分"标签
                                mdata["vote_average"] = tmpElem
                                -- elseif xml_tv_nfo:name() == "sorttitle" then
                                --     mdata["sort_title"] = tmpElem
                            elseif xml_tv_nfo:name() == "mpaa" then
                                -- "媒体分级/mpaa"标签
                                mdata["rate_mpaa"] = tmpElem
                            elseif xml_tv_nfo:name() == "tmdbid" then
                                -- "tmdb的ID"标签
                            mdata["media_id"] = string.format("%d", tonumber(tmpElem))
                                -- if mdata["media_id"] ~= nil then
                                --     mdata[""] = "https://www.themoviedb.org/movie/" .. mdata["media_id"]
                                -- end
                            elseif xml_tv_nfo:name() == "imdbid" then
                                -- "imdb的id"标签
                                mdata["media_imdbid"] = tmpElem
                            elseif xml_tv_nfo:name() == "country" then
                                -- "国家"标签
                                if mdata["origin_country"] == nil then
                                    mdata["origin_country"] = {}
                                end
                                table.insert(mdata["origin_country"], tmpElem)
                            elseif xml_tv_nfo:name() == "genre" then
                                -- "流派类型-名称"标签
                                if mdata["genre_names"] == nil then
                                    mdata["genre_names"] = {}
                                end
                                table.insert(mdata["genre_names"], tmpElem)
                            elseif xml_tv_nfo:name() == "studio" then
                                -- "出品 公司/工作室"标签
                                if mdata["production_company"] == nil then
                                    mdata["production_company"] = {}
                                end
                                table.insert(mdata["production_company"], tmpElem)
                            elseif xml_tv_nfo:name() == "director" then
                                -- "导演"标签
                                if mdata["person_crew"] == nil then
                                    mdata["person_crew"] = ''
                                end
                                if not string.isEmpty(tmpElem) then
                                    table.insert(mdata["person_crew"],{
                                        ["name"]= tmpElem or"",
                                        ["original_name"]= tmpElem or"",
                                        ["department"]= "Directing",
                                        ["job"]= "Director",
                                    })
                                end
                            mdata["person_staff"] = mdata["person_staff"] .. "Director:" .. tmpElem .. ';' -- Director-zh
                            elseif xml_tv_nfo:name() == "actor" then
                                -- "演员"标签组
                                if mdata["person_cast"] == nil then
                                    -- 初始化table
                                    mdata["person_cast"] = {}
                                end
                            local cname, cactor, clink, cimgurl = nil, nil, nil, nil
                                -- read actors of tv
                                xml_tv_nfo:readnext()
                            while xml_tv_nfo:name() ~= "actor" or not (not xml_tv_nfo:startelem()) do
                                -- 循环，直到读取到"演员"的结束标签
                                if xml_tv_nfo:startelem() then
                                    tmpElem = xml_tv_nfo:elemtext() .. ""
                                    if xml_tv_nfo:name() == "role" then
                                        -- "角色名"标签
                                        cname = tmpElem
                                    elseif xml_tv_nfo:name() == "name" then
                                        -- "演员名"标签
                                        cactor = tmpElem
                                    end
                                    -- kiko.log('TEST  - Actor tag <'..xml_tv_nfo:name()..'>'..tmpElem)
                                end
                                xml_tv_nfo:readnext()
                            end
                            table.insert(mdata["person_cast"], {
                                ["name"] = cname, -- 人物名称
                                ["original_name"] = cname, -- 人物名称
                                ["character"] = cactor, -- 演员名称
                                ["department"]= "Actors",
                                ["job"]="Actor",
                            })
                        end
                        -- kiko.log('[INFO]  Reading tag <' .. xml_tv_nfo:name() .. '>' .. tmpElem)
                    end
                    xml_tv_nfo:readnext()
                end
                xml_tv_nfo:clear()

                -- 添加本地海报/背景图片
                -- TODO 此处功能无效：传入的是 "D:/.../poster.jpg"
                local file_exist_test, file_exist_test_err, path_file_image_tmp
                    if mdata["season_number"] ~= nil then
                        if mdata["season_number"] ~= "0" then
                            -- 普通季
                            path_file_image_tmp = path_folder_lf .. "season" ..
                                 string.format('S%02d', mdata["season_number"]) .. "-poster.jpg" -- season08-poster.jpg
                        else
                            -- 特别篇
                            path_file_image_tmp = path_folder_lf .. "season" ..
                                                  string.format('-specials', mdata["season_number"]) .. "-poster.jpg" -- season-specials-poster.jpg
                        end
                    file_exist_test, file_exist_test_err = io.open(path_file_image_tmp)
                        if file_exist_test_err == nil then
                            -- 文件存在
                            io.close(file_exist_test)
                            mdata["poster_path"] = path_file_image_tmp
                        else
                            mdata["poster_path"] = path_folder_lf .. "poster.jpg"
                        end
                        mdata["background_path"] = path_folder_lf .. "fanart.jpg"
                    end
                    -- kiko.log("match - poster_path > ".. mdata["poster_path"])
                    -- 把媒体信息<table>转为json的字符串
                local err, ts_data_json = kiko.table2json(table.deepCopy(mdata))
                    if err ~= nil then
                        kiko.log(string.format("[ERROR] table2json: %s", err))
                    end
                    -- get "TV Name S01"
                    if mdata["season_number"] ~= nil then
                        -- 不处理 tstitle 里的特殊 季标题
                        if not (Metadata_info_origin_title) then
                            -- 目标语言标题
                        mname = mdata["media_title"] .. ' 第' .. mdata["season_number"] .. "季"
                        else
                            -- 原语言标题
                        mname = mdata["original_title"] .. string.format(' S%02d', mdata["season_number"])
                        end
                        -- mediainfo["data"] = mdata .. '/season/' .. mdata["season_number"]
                        -- mediainfo["url"] = "https://www.themoviedb.org/tv/" .. mdata
                    else
                        if not (Metadata_info_origin_title) then
                            mname = mdata["media_title"]
                        else
                            mname = mdata["original_title"]
                        end
                    end
                    -- 媒体信息表
                    mediainfo = {
                        ["name"] = mname, -- 动画名称
                        ["data"] = ts_data_json -- 脚本可以自行存放一些数据
                        -- ["url"] = murl, -- 条目页面URL
                        -- ["desc"] = mdesc, -- 描述
                        -- ["airdate"] = mairdate, -- 放送日期，格式为yyyy-mm-dd
                        -- ["epcount"]=mepcount,       --分集数
                        -- ["coverurl"]=mcoverurl,      --封面图URL
                        -- ["staff"] = mstaff, -- staff
                        -- ["crt"] = mcrt -- 人物
                    }
                    -- 从 媒体信息的发行日期/年份 获取年份字符串，加到剧集名称+季序数后，以防重名导致kiko数据库错误。形如 "剧集名 第2季 (2010)"
                if mdata["release_date"] ~= nil and mdata["release_date"] ~= "" then
                    mediainfo["name"] = mediainfo["name"] ..
                                            string.format(' (%s)', string.sub(mdata["release_date"], 1, 4))
                    end
                    epinfo = {
                        ["name"] = ename, -- 分集名称
                        ["index"] = eindex, -- 分集编号（索引）
                        ["type"] = etype -- 分集类型
                    }
                    break
                end
            end
            xml_v_nfo:readnext()
        end
        xml_v_nfo:clear()
        kiko.log("[INFO]  TMDb matching succeeded.")

        mediainfo["scriptId"] = "Kikyou.l.TMDb"
        --[[
        -- kiko.log("[INFO]  <mediainfo>")
        -- kiko.log(table.toStringBlock(mediainfo))
        -- kiko.log("[INFO]  <epinfo>")
        -- kiko.log(table.toStringBlock(epinfo))
        -- kiko.log("TEST  - others")
        -- kiko.log("| mname, mdata, murl, mairdate, myear | ename, eindex, etype, | mdata["season_number"], tstitle |")
        -- kiko.log("| mname, mdata, myear | ename, eindex, etype, | eseason, tstitle |")
        -- kiko.log('|', mname, '*', mdata, '*', murl, '*', mairdate, '*', myear)
        -- kiko.log('|', mname, '*', table.toStringLine(mdata), '*', myear)
        -- kiko.log('|', ename, '*', tostring(eindex), '*', tostring(etype))
        -- kiko.log('|', tostring(eseason), '*', tstitle, '|')
        ]]--

        -- 返回 MatchResult格式
        return {
            ["success"] = true,
            ["anime"] = mediainfo,
            ["ep"] = epinfo
        }
    end

    kiko.log("Failed to match.")
    return {
        ["success"] = false,
        ["anime"] = {},
        ["ep"] = {},
    }
    -- ::continue_match_a::
end

-- Table，类型为 Array[LibraryMenu]
-- 如果资料库条目的scriptId和当前脚本的id相同，条目的右键菜单中会添加menus包含的菜单项，用户点击后会通过menuclick函数通知脚本
menus = {{
        ["title"] = "打开媒体主页",
        ["id"] = "open_webpage_media_home",
    },{
        ["title"] = "打开TMDb/IMDb",
        ["id"] = "open_webpage_media_tmdb_imdb",
    },{
        ["title"] = "使用豆瓣/贴吧搜索",
        ["id"] = "open_webpage_douban_tieba",
    },{
        ["title"] = "打开fanart",
        ["id"] = "open_webpage_media_fanart",
    },{
        ["title"] = "使用字幕搜索",
        ["id"] = "open_webpage_multiple_subtitle",
    },{
        ["title"] = "显示媒体元数据",
        ["id"] = "show_media_matadata",
}}

-- 用户点击条目的右键菜单中的menus菜单后，会通过menuclick函数通知脚本
function menuclick(menuid, anime)
    -- menuid： string，点击的菜单ID
    -- anime： Anime， 条目信息
    -- 返回：无
    local NM_HIDE = 1 -- 一段时间后自动隐藏
    local NM_PROCESS = 2 -- 显示busy动画
    local NM_SHOWCANCEL = 4 -- 显示cancel按钮
    local NM_ERROR = 8 -- 错误信息
    local NM_DARKNESS_BACK = 16 -- 显示暗背景，阻止用户执行其他操作
    kiko.log("Menu Click: ", menuid)
    local err, anime_data = kiko.json2table(anime["data"])
    if err ~= nil then
        kiko.log(string.format("[ERROR] json2table: %s", err))
    end
    if anime_data["media_type"] == nil then
        -- 无媒体类型信息
        kiko.log("[WARN]  (AnimeLite)anime[\"data\"][\"media_type\"] not found.")
    end
    if anime_data.season_title == string.format("第 %d 季", anime_data.season_number) then
        anime_data.season_title= string.format("第%d季", anime_data.season_number)
    end

    if menuid == "open_webpage_media_tmdb_imdb" then
        kiko.log("Open TMDb page of <"..anime["name"]..">.")
        if not string.isEmpty(anime["url"]) then
            kiko.message("打开 <"..anime["name"].."> 的TMDb页面", NM_HIDE)
            kiko.execute(true, "cmd", {"/c", "start", anime["url"]})
        else
            kiko.message("未找到 <"..anime["name"].."> 的TMDb页面。\n请右键资料库的媒体尝试重新刮削详细信息。", NM_HIDE|NM_ERROR)
        end
        kiko.log("Open IMDb page of <"..anime["name"]..">.")
        if not string.isEmpty(anime_data.imdb_id) then
            kiko.message("打开 <"..anime["name"].."> 的IMDb页面", NM_HIDE)
            kiko.execute(true, "cmd", {"/c", "start", "https://www.imdb.com/title/"..anime_data.imdb_id})
        else
            kiko.message("未找到 <"..anime["name"].."> 的IMDb页面。\n请右键资料库的媒体尝试重新刮削详细信息。", NM_HIDE|NM_ERROR)
        end
    elseif menuid == "open_webpage_douban_tieba" then
        kiko.log("Open douban page of <"..anime["name"]..">.")
        if not string.isEmpty(anime_data.media_title) then
            kiko.message("打开 <"..anime["name"].."> 的豆瓣页面", NM_HIDE)
            kiko.execute(true, "cmd", {"/c", "start", "https://www.douban.com/search?cat=1002^&q=".. string.gsub(anime_data.media_title.." ".. (anime_data.season_title or""),
                    "[ %c%p\'\"%^%&%|<>]","%%20")})
        else
            kiko.message("未找到 <"..anime["name"].."> 的豆瓣页面。\n请右键资料库的媒体尝试重新刮削详细信息。", NM_HIDE|NM_ERROR)
        end
        kiko.log("Open tieba page of <"..anime["name"]..">.")
        if not string.isEmpty(anime_data.media_title) then
            kiko.message("打开 <"..anime["name"].."> 的贴吧页面", NM_HIDE)
            kiko.execute(true, "cmd", {"/c", "start", "https://tieba.baidu.com/f/search/fm?ie=UTF-8^&qw=".. string.gsub(anime_data.media_title, "[ %c%p%^%&%|<>]", "%%20")})
        else
            kiko.message("未找到 <"..anime["name"].."> 的贴吧页面。\n请右键资料库的媒体尝试重新刮削详细信息。", NM_HIDE|NM_ERROR)
        end
    elseif menuid == "open_webpage_media_home" then
        kiko.log("Open home page of <"..anime["name"]..">.")
        if not string.isEmpty(anime_data.homepage_path) then
            kiko.message("打开 <"..anime["name"].."> 的媒体主页", NM_HIDE)
            kiko.execute(true, "cmd", {"/c", "start", string.gsub(anime_data.homepage_path, "([%^%&%|<>])", "^%1") })
        else
            kiko.message("未找到 <"..anime["name"].."> 的媒体主页。", NM_HIDE|NM_ERROR)
        end
    elseif menuid == "open_webpage_media_fanart" then
        kiko.log("Open fanart page of <"..anime["name"]..">.")
        if anime_data.media_type=="movie" then
            if not string.isEmpty(anime_data.media_id) then
                kiko.message("打开 <"..anime["name"].."> 的fanart页面", NM_HIDE)
                kiko.execute(true, "cmd", {"/c", "start", "https://fanart.tv/movie/"..anime_data.media_id})
            else
                kiko.message("未找到 <"..anime["name"].."> 的fanart页面。\n请右键资料库的媒体尝试重新刮削详细信息。", NM_HIDE|NM_ERROR)
            end
        elseif anime_data.media_type=="tv" then
            if not string.isEmpty(anime_data.tvdb_id) then
                kiko.message("打开 <"..anime["name"].."> 的fanart页面", NM_HIDE)
                kiko.execute(true, "cmd", {"/c", "start", "https://fanart.tv/series/"..anime_data.tvdb_id})
            else
                kiko.message("未找到 <"..anime["name"].."> 的fanart页面。\n请右键资料库的媒体尝试重新刮削详细信息。", NM_HIDE|NM_ERROR)
            end
        else
            kiko.message("未找到 <"..anime["name"].."> 的fanart页面。\n请右键资料库的媒体尝试重新刮削详细信息。", NM_HIDE|NM_ERROR)
        end
    elseif menuid == "open_webpage_multiple_subtitle" then
        kiko.log("Open multiple subtitle page of <"..anime["name"].."> by IMDb id.")
        kiko.message("打开 <"..anime["name"].."> 的字幕搜索页面", NM_HIDE)
        
        local tmpLangO, tmpSeasont, tmpTitleO, tmpTitleM = "","","", ""
        tmpLangO= (string.isEmpty(anime_data.original_language) and{"en"} or{anime_data.original_language})[1]
        if not string.isEmpty(anime_data.original_title or anime_data.original_title) then
            if anime_data.media_type=="tv" and not string.isEmpty(anime_data.season_number) and tonumber(anime_data.season_number)~=nil then
                tmpSeasont=tmpSeasont.."%20S"..string.format("%02d",math.floor(tonumber( anime_data.season_number )))
            end
            tmpTitleM= string.gsub(anime_data.media_title or"" ,"[ %c%p%^%&%|<>]","+")
            if tmpLangO=="en" then
                tmpTitleO= (string.isEmpty(anime_data.original_title)and{anime_data.media_title}or{anime_data.original_title})[1]
                tmpTitleO= string.gsub(tmpTitleO,"[ %c%p%^%&%|<>]","+")
            else
                tmpTitleO= tmpTitleM
            end
            
            kiko.message("媒体<"..anime.name..">的标题 已复制至剪切板", NM_HIDE)
            kiko.execute(true, "cmd", {"/c", "set/p=", string.gsub(anime_data.media_title.." "..anime_data.original_title.." "..
                    (string.isEmpty(anime_data.season_title) and{ "" }or{ anime_data.season_title })[1] ,"([\"])", " "),"<nul|clip"})
            kiko.execute(true, "cmd", {"/c", "start", "https://zmk.pw/search?q="..tmpTitleO})
            kiko.execute(true, "cmd", {"/c", "start", "https://subhd.tv/search/"..string.gsub(tmpTitleO,"[ %c%p%^%&%|<>]","%%20")})
            kiko.execute(true, "cmd", {"/c", "start", "https://www.yysub.net/search/index?keyword="..tmpTitleO.."^&search_type="})
            kiko.execute(true, "cmd", {"/c", "start",
                    "https://bbs.acgrip.com/search.php?mod=forum^&searchid=^&orderby=lastpost^&ascdesc=desc^&searchsubmit=yes^&kw="..tmpTitleM})
        end
        if not string.isEmpty(anime_data.imdb_id) then
            kiko.execute(true, "cmd", {"/c", "start", "https://www.opensubtitles.com/zh-CN/zh-CN,zh-TW,"..tmpLangO..
                        "/search-all/q-".. anime_data.imdb_id.. "/hearing_impaired-include/machine_translated-include/trusted_sources-"})
        else
            kiko.message("未找到 <"..anime["name"].."> 的IMDb id。\n请右键资料库的媒体尝试重新刮削详细信息。", NM_HIDE|NM_ERROR)
        end
    elseif menuid == "show_media_matadata" then
        -- 显示媒体元数据
        -- kiko.log(os.time)
        -- local tipString="" -- 显示的媒体元数据文本
        -- 把媒体信息"data"的json的字符串转为<table>
        -- table.toStringLog(anime_data) -- kiko.log("")
        local tmpString, tipString = "", ""
        -- 格式化输出字符串
        tmpString = anime["name"]
        tipString = tipString .. "媒体标题：\t" .. (tmpString or "")
        tipString = tipString .. "\n标题：\t\t" .. (anime_data.media_title or "")
        tipString = tipString .. "\n原标题：\t\t" .. (anime_data["original_title"] or "")
        if anime_data["media_type"]=="movie" then
            tipString = tipString .. "\n首映：\t\t"
        elseif anime_data["media_type"]=="tv" then
            tipString = tipString .. "\n季标题：\t\t" .. (anime_data.season_title or "")
            tipString = tipString .. "\n首播：\t\t"
        else tipString = tipString .. "\n首映/首播：\t"
        end
        tmpString = anime["airdate"]
        tipString = tipString .. (tmpString or anime_data["release_date"] or "")

        tipString = tipString .. "\n\n媒体类型：\t"
        if anime_data["media_type"] == "movie" then
            tipString = tipString .. "电影"
        elseif anime_data["media_type"] == "tv" then
            tipString = tipString .. "剧集"
        else tipString = tipString .. "其他"
        end
        if not string.isEmpty(anime_data["tv_type"]) then
            tipString = tipString .. ", " .. anime_data["tv_type"]
        end
        if not string.isEmpty(anime_data["status"]) then
            tipString = tipString .. "\n播映状态：\t".. (Status_tmdb[anime_data["status"]] or anime_data["status"])
            if anime_data["tv_in_production"]==true or anime_data["tv_in_production"]=="true" then
                tipString = tipString ..", 未完结"
            end
        end
        if not table.isEmpty(anime_data.mo_belongs_to_collection) and not string.isEmpty(anime_data.mo_belongs_to_collection.name) then
            tipString = tipString .. "\n所属系列：\t" .. anime_data.mo_belongs_to_collection.name
        end
        tipString = tipString .. "\n流派：\t\t" .. (Array.toStringLine(anime_data["genre_names"]) or "")
        if anime_data["mo_is_adult"]==true or anime_data["mo_is_adult"]=="true" then
            tipString = tipString .. ", 成人"
        end
        local mediaLang= {anime_data["original_language"]}
        Array.extendUnique(mediaLang,anime_data["spoken_language"],"iso_639_1")
        Array.extendUnique(mediaLang,anime_data["tv_language"])
        local mediaCountry= table.deepCopy(anime_data["origin_country"])
        Array.extendUnique(mediaCountry,anime_data["production_country"],"iso_3166_1")
        local mediaCompany={}
        Array.extendUnique(mediaCompany,anime_data["production_company"],"name")
        -- Array.extendUnique(mediaCompany,anime_data["tv_network"],"name")
        local mediaNetwork={}
        Array.extendUnique(mediaNetwork,anime_data["tv_network"],"name")
        if not table.isEmpty(mediaLang) then
            tipString = tipString .. "\n语言：\t\t" .. (Array.toStringLine(mediaLang) or "")
        end
        if not table.isEmpty(mediaCountry) then
            tipString = tipString .. "\n地区：\t\t" .. (Array.toStringLine(mediaCountry) or "")
        end
        if not table.isEmpty(mediaCompany) then
        tipString = tipString .. "\n出品方：\t\t" .. (Array.toStringLine(mediaCompany) or "")
        end
        if not table.isEmpty(mediaNetwork) then
            tipString = tipString .. "\n播映平台：\t" .. (Array.toStringLine(mediaNetwork) or "")
        end

        tipString = tipString .. "\n"
        if not string.isEmpty(anime_data["tagline"]) then
            tipString = tipString .. "\n标语：\t\t".. (Status_tmdb[anime_data["tagline"]] or anime_data["tagline"])
        end
        tmpString = anime["epcount"]
        if anime_data["media_type"]~="movie" then
            tipString = tipString .. "\n分集总数：\t" .. (tmpString or tostring(math.floor(tonumber(anime_data["episode_count"]))) or "")
        end
        if not string.isEmpty(anime_data["runtime"]) then
            tipString = tipString .. "\n时长：\t\t" .. anime_data["runtime"][1]
        end
        if not string.isEmpty(anime_data["vote_average"]) then
            tipString = tipString .. "\nTMDb评分：\t" .. (anime_data["vote_average"] or "")
        end
        if not string.isEmpty(anime_data["mo_budget"]) then
            tipString = tipString .. "\n预算：\t\t" .. anime_data["mo_budget"]
        end
        if not string.isEmpty(anime_data["mo_revenue"]) then
            tipString = tipString .. "\n收入：\t\t" .. anime_data["mo_revenue"]
        end
        if not string.isEmpty(anime_data["tv_first_air_date"]) then
            tipString = tipString .. "\n剧集首播：\t" .. anime_data["tv_first_air_date"]
        end
        if not string.isEmpty(anime_data["tv_last_air_date"]) then
            tipString = tipString .. "\n剧集最新：\t" .. anime_data["tv_last_air_date"]
        end
        if not string.isEmpty(anime_data["homepage_path"]) then
            tipString = tipString .. "\n媒体主页：\t" .. anime_data["homepage_path"]
        end
        if not string.isEmpty(anime_data["imdb_id"]) then
            tipString = tipString .. "\nIMDb：\t\t" .. anime_data["imdb_id"]
        end
        if not string.isEmpty(anime_data["tvdb_id"]) then
            tipString = tipString .. "\nTVDb：\t\t" .. anime_data["tvdb_id"]
        end
        tmpString = anime["url"]
        tipString = tipString .. "\nTMDb链接：\t" .. (tmpString or "")
        tmpString = anime["coverurl"]
        tipString = tipString .. "\n封面链接：\t" .. Image_tmdb.prefix..Image_tmdb.poster[Image_tmdb.max_ix] ..  (tmpString or anime_data["poster_path"] or "")
        tipString = tipString .. "\n背景链接：\t" .. Image_tmdb.prefix..Image_tmdb.backdrop[Image_tmdb.max_ix] ..  (tmpString or anime_data["background_path"] or "")
        local function getStrFanartImage(value, fiType)
            local tmpLine="\n"
            tmpLine= tmpLine..string.format("%4s",fiType or "").."("..string.format("%2s",value.lang or"")
            if not string.isEmpty(value.disc_type) then
                tmpLine= tmpLine..","..string.format("%6s",value.disc_type or"")
            end
            if not string.isEmpty(value.season) then
                tmpLine= tmpLine..","..string.format("%02s",value.season or"")
            end
            tmpLine= tmpLine.. ")\t"
            if not string.isEmpty(value.url) then
                tmpLine= tmpLine..Image_fanart.prefix..Image_fanart.size[2]..(value.url or"")
            end
            return tmpLine
        end
        for fTypei, value in pairs(anime_data.fanart_path or {}) do
            for oisField, oisPath in pairs(value) do
                if oisField=="origin" then
                    tipString = tipString .. getStrFanartImage(oisPath,Image_fanart.type_zh[fTypei].." ")
                elseif oisField=="interf" then
                    tipString = tipString .. getStrFanartImage(oisPath,Image_fanart.type_zh[fTypei].."+")
                end
            end
        end

        tipString = tipString .. "\n"
        tipString = tipString .. (string.isEmpty(anime_data.overview_season) and{""}or{ "\n本季剧情：\t" .. (anime_data.overview_season or "") })[1]
        tipString = tipString .. "\n"..((anime_data.media_type~="movie")and{"剧集"}or{"电影"})[1] .."介绍：\t" .. (anime_data.overview or "")
        
        tipString = tipString .. "\n\n演员表：\t\t\n"
        if table.isEmpty(anime_data.person_cast) then
            for _, value in ipairs(anime.crt or {}) do
                tipString = tipString ..""..string.format("%s",value.actor or"").."\t\t\t"..value.name.."\n"
            end
        else
            for _, value in ipairs(anime_data.person_cast or {}) do
                tipString = tipString ..""..string.format("%s",value.original_name or"").."\t\t\t"..value.character.."\n"
            end
        end
        tipString = tipString .. "\n职员表：\t\t\n"
        if table.isEmpty(anime_data.person_crew) then
            for djobstr, value in ipairs(anime.staff or {}) do
                tipString = tipString..""..string.format("%s",djobstr or "").."\t\t\t"..(value or"").."\n"
            end
        else
            for _, value in ipairs(anime_data.person_crew or {}) do
                tipString = tipString..""..string.format("%s",(value.department or "")..( string.isEmpty(value.job) and{""}or{
                    " - "..value.job})[1]) .."\t\t\t"..value.original_name.."\n"
            end
        end
        local dataString = ""
        if anime_data == nil then
            -- 无媒体信息
            kiko.log("[WARN]  (AnimeLite)anime[\"data\"] not found.")
        else
            -- 有anime["data"]字段
            dataString = table.toStringBlock(anime_data or "", 1) .. dataString
        end
        tipString = tipString .. "\n\n其他：\t\n" .. dataString --

        -- tipString=string.gsub(tipString,"\t","    ")
        -- kiko.log(tipString)
        -- kiko.log(dataString)
        -- kiko.dialog 疑似不支持多行显示？
        -- resTF ∈ ["accept","reject"]
        
        -- 获取 背景图 的二进制数据
        -- local sizeOfFanart,sizeOfTMDb = 2,5
        local mImgPTmp = "TMDb_prior"
        if settings["metadata_image_priority"]=="fanart_only"
            or settings["metadata_image_priority"]=="TMDb_only"
            or settings["metadata_image_priority"]=="TMDb_prior" then
            mImgPTmp= settings["metadata_image_priority"]
        end
        local miotTmp = settings['metadata_info_origin_title']
        if (miotTmp == '0') then
            Metadata_info_origin_image = false
        elseif (miotTmp == '1') then
            Metadata_info_origin_image = true
        end
        local function getImgPath(sign)
            local paramImgFth={ ["poster"]= {["img_fx"]=1,["tmdb_path"]="poster_path",["header_suffix"]="jpeg",},
                            ["banner"]= {["img_fx"]=2,["header_suffix"]="jpeg",},
                            ["thumb"]= {["img_fx"]=3,["header_suffix"]="jpeg",},
                            ["background"]= {["img_fx"]=4,["tmdb_path"]="background_path",["header_suffix"]="jpeg",},
                            ["logo"]= {["img_fx"]=5,["header_suffix"]="png",},
                            ["logoL"]= {["img_fx"]=6,["header_suffix"]="png",},
                            ["art"]= {["img_fx"]=7,["header_suffix"]="png",},
                            ["artL"]= {["img_fx"]=8,["header_suffix"]="png",},
                            ["otherart"]= {["img_fx"]=9,["header_suffix"]="png",},
                        }
            local paramImgPath= paramImgFth[sign]
            if paramImgPath==nil then return "" end
            local backgUrlTmp ,backgUrlTmpP = "",""
            if mImgPTmp=="TMDb_prior" or mImgPTmp=="TMDb_only" then
                backgUrlTmp = anime_data[paramImgPath["tmdb_path"] or""]
                if not string.isEmpty(backgUrlTmp) then
                    backgUrlTmpP = Image_tmdb.prefix..Image_tmdb.backdrop[Image_tmdb.min_ix] .. backgUrlTmp
                    backgUrlTmp = Image_tmdb.prefix..Image_tmdb.backdrop[Image_tmdb.max_ix] .. backgUrlTmp
                end
            end
            if mImgPTmp=="fanart_only" or (string.isEmpty(backgUrlTmp) and mImgPTmp=="TMDb_prior") then
                if anime_data.media_type=="tv" then
                    if Metadata_info_origin_image==true then
                        backgUrlTmp = ((((anime_data.fanart_path or{})[Image_fanart["season"][paramImgPath.img_fx or 4]] or{}).origin or{}).url or"")
                    else
                        backgUrlTmp = ((((anime_data.fanart_path or{})[Image_fanart["season"][paramImgPath.img_fx or 4]] or{}).interf or{}).url or"")
                    end
                end
                if not string.isEmpty(backgUrlTmp) then
                    backgUrlTmp = backgUrlTmp
                else
                    if Metadata_info_origin_image==true then
                        backgUrlTmp = ((((anime_data.fanart_path or{})[Image_fanart[anime_data.media_type] [paramImgPath.img_fx or 4]] or{}).origin or{}).url or"")
                    else
                        backgUrlTmp = ((((anime_data.fanart_path or{})[Image_fanart[anime_data.media_type] [paramImgPath.img_fx or 4]] or{}).interf or{}).url or"")
                    end
                end
                if not string.isEmpty(backgUrlTmp) then
                    backgUrlTmpP = Image_fanart.prefix..Image_fanart.size[Image_fanart.min_ix]..backgUrlTmp
                    backgUrlTmp = Image_fanart.prefix..Image_fanart.size[Image_fanart.max_ix]..backgUrlTmp
                elseif mImgPTmp=="fanart_prior" then
                    backgUrlTmp = anime_data["poster_path"]
                    if not string.isEmpty(backgUrlTmp) then
                        backgUrlTmpP = Image_tmdb.prefix..Image_tmdb.poster[Image_tmdb.min_ix] .. backgUrlTmp
                        backgUrlTmp = Image_tmdb.prefix..Image_tmdb.poster[Image_tmdb.max_ix] .. backgUrlTmp
                    end
                end
            end
            return {["path"]=backgUrlTmp,["path_preview"]=backgUrlTmpP,["header_suffix"]=paramImgPath.header_suffix or"jpeg"}
        end


        local img_back_data=nil
        local tmpImgPath=getImgPath(settings["metadata_display_imgtype"] or Metadata_display_imgtype)
        if not table.isEmpty(tmpImgPath) then
            local header = {["Accept"] = "image/"..tmpImgPath.header_suffix}
            local err, reply = kiko.httpget(tmpImgPath.path, {} , header)
            if err ~= nil then
                kiko.log("[ERROR] TMDb.API.reply-showmnfo.httpget: " .. err)
                err, reply = kiko.httpget(tmpImgPath.path_preview, {} , header)
                if err ~= nil then
                    kiko.log("[ERROR] TMDb.API.reply-showmnfo.httpget: " .. err)
                    goto jumpover_metadatadisplay_img_scraping
                end
            end
            img_back_data=reply["content"]
        end
        -- kiko.log(reply)
        --[[
        local rf=io.open(sourcePath,"rb")
        local len = rf:seek("end")
        rf:seek("set",0)= rf:read(len)
        img_back_data = rf:read(len)
        ]]--
        ::jumpover_metadatadisplay_img_scraping::
        local resTF, resText = kiko.dialog({
            ["title"] = anime["name"] .. " - 元数据", -- 对话框标题，可选
            ["tip"] = "> 此处的编辑不可保存哦~", -- 对话框提示信息
            ["text"] = tipString, -- 可选，存在这个字段将在对话框显示一个可供输入的文本框，并设置text为初始值
            ["image"]=img_back_data,   --可选，内容为图片数据，存在这个字段将在对话框内显示图片
        })
        if resTF == "accept" then
            kiko.message("此处的编辑不可保存哦~", NM_HIDE)
        end
    end
end

-- 对修改设置项`settings`响应。KikoPlay当 设置中修改了脚本设置项 时，会尝试调用`setoption`函数通知脚本。
-- key为设置项的key，val为修改后的value
function setoption(key, val)

    -- 显示设置更改信息
    kiko.log(string.format("[INFO]  Settings changed: %s = %s", key, val))
end

---------------------
-- 功能函数
--

-- 从文件名获取粗识别的媒体信息
-- return: (table):{Title|SeasonNum|EpNum|EpExt|TitleExt|EpType}
function Path.getMediaInfoRawByFilename(filename)
    if filename == nil or filename=="" or type(filename)~="string" then
        return {"","","","","",""}
    end
    
	local res={}		-- 结果 Result:		Title|SeasonNum|EpNum|EpExt|TitleExt|EpType
	local resTS={}	-- 粗提取 ResultRaw:	TitleRaw|SeasonEpRaw
	local resSext={}	-- 季集 SeasonEpInfo: SeasonNum|EpNum|EpExt|TitleExt|Eptype

    -- kiko.regex([[...]],"options"):gsub("target","initpos")
    -- kiko.regex([[...]],"options"):gmatch("target","repl")
    -- kiko.regex([[...]],"options"):gsub("target","repl")
    
    -- kiko.regex不能多开，需要依次，否则会后来的替代掉之前的
    -- 普通集:标题-季集 regex: (Title)(.)(S01E02)... |  (Title)(.)(第一季第二集)...
    local patternSE=[[^([^\t\r\n]{0,}?)([ \-\.\[])((([Ss]{0,1}(\d{1,}[Ee]|(?<=[Ss \-\.\]\[])\d{1,2}[Xx])\d{1,}([\-]\d{1,3}|))|([Ee][Pp]{0,1}\d{1,}([\-\.]\d{1,3}|))|(第(\d{1,}|[〇零一二三四五六七八九十]{1,5})(([季部][ \-\.]{0,3}第{0,1}(\d{1,}|([〇零一二三四五六七八九十]{1,5}))([—\-\.]\d{1,3}|)[話话集]{0,1})|([\-\.]\d{1,3}|)[話话集]{0,1}))|(?<![ \.\[][HhXx]\.)\d{2,3}([\-\.]\d{1,}|)(?!\.))(?=[ \-\.\[\]\(\)])(?!p))([^\t\r\n]{0,})$]]
    
    -- 阿拉伯数字:季集 regex: (S)(01)(E)(02)(-)(03) | ()()(EP)(02)()()
    local patternSENum=[[^([Ss]|第{0,1}?|)(\d{1,}(?=[EeXx季部第]|[話集]\d{1,})|)([EeXx]|[Ee][Pp]{0,1}|[季部][ \-\.]{0,3}|[季部]{0,1}[ \-\.]{0,3}[第話集]|)(\d{1,})([話集]{0,1}[\-\.]{0,1}|)(\d{1,}|)$]]
    -- 含中文数字:季集 regex: (第)(一)()(季第)(二)(-)(三)(集)...
    local patternSEZh=[[^(第|)((\d{1,}|[〇零一二三四五六七八九十]{1,5})(?=[季部第])|)([季部][ \-\.]{0,3}第{0,1}|第)(\d{1,}|[〇零一二三四五六七八九十]{1,5})([—\-\.]{0,1})((\d{1,}|[〇零一二三四五六七八九十]{1,5})|)([話话集]{0,1})$]]

    -- 特别篇:标题 regex: (Title)(.)(SP)...
    local patternSp=[[^([^\t\r\n]{0,}?)([ \-\.\[])((([Ss第](\d{1,}|[〇零一二三四五六七八九十]{1,5}[季部]{0,1}))[ \-\.\(\)\[\]\{\}].{0,}|[^ \-\.\(\)\[\]\{\}\t\r\n]+?|)([Ss]pecial[s]{0,1}|[Ee]xtra[s]{0,1}|[Ss][Pp]|([^ \-\.\(\)\[\]\{\}\t]{0,}特[别別典][篇编編片]{0,1})|[Oo][Pp]|片[頭头]曲{0,1}|[Ee][Dd]|片尾曲{0,1}|[Tt]railer[s]{0,1}|[Cc][Mm]|[Pp][Vv]|[预預予][告][篇编編片]{0,1})([ \-\.]{0,3}\d+[\] \.]|)|([Ss第](\d{1,}|[〇零一二三四五六七八九十]{1,5}[季部])[^ \-\.\(\)\[\]\{\}\t\r\n]{1,}))(?=[\] \-\.])(?!p)([^\t\r\n]{0,})$]]
    -- 特别篇所在季序数: regex: (S01)...
    local patternSpSeason=[[^.{0,}?([Ss]|第)(\d{1,}|[〇零一二三四五六七八九十]{1,5}(?=[季部第])).{0,}$]]
    local patternSpSp=[[.{0,}?([Ss]pecial[s]{0,1}|[Ee]xtra[s]{0,1}|[Ss][Pp]|特[别別典][篇编編片]{0,1}).{0,}]]
    local patternSpTr=[[.{0,}?([Tt]railer[s]{0,1}|[Cc][Mm]|[Pp][Vv]|[预預予][告][篇编編片]{0,1}).{0,}]]
    local patternSpOp=[[.{0,}([Oo][Pp]|片[頭头]曲{0,1}).{0,}]]
    local patternSpEd=[[.{0,}?([Ee][Dd]|片尾曲{0,1}).{0,}]]

    -- 仅标题 regex: (Title)(-)()...
    local patternNum=[[^([^\t\r\n]{0,}?)([ \-\.\[\]\(\)]{1,3})(\d{1,3}(?=[ \-\.\[\]\(\)]{1,3})|([Ss第](\d{1,}|[〇零一二三四五六七八九十]{1,5}[季部])[ \-\.]{0,3}[^ \-\.\(\)\[\]\{\}\t\r\n]{0,})|)(?=([ \-\.\[\]\(\)]{0,3})((\d{4})|(\d{3,4}[pPiIkK])|([34][dD])|([hHxX][\-\.]{0,1}26[45])|(-[ \.])|(\[)|(DVD|HDTV|(WEB|[^ \-\.\(\)\[\]\{\}\t\r\n]{0,})([\-]{0,1}DL|[Rr]ip)|BD[Rr]ip|[Bb]lu\-{0,1}[Rr]ay)|((avi|flv|mpg|mp4|mkv|rm|rmvb|ts|wmv)$)))([^\t\r\n]{0,})$]]

    -- 普通集: filename->ResultRaw
	resTS=string.split(kiko.regex(patternSE,"i"):gsub(filename,"\\1\t\\3"),"\t")
	if resTS[1] ~= filename then
		while #resTS<2 do
			table.insert(resTS,"") -- 补全长度
        end
        -- 仅数字的集: SeasonEpRaw->SeasonEpInfo
		resSext=string.split(kiko.regex(patternSENum,"i"):gsub(resTS[2],"\\2\t\\4\t\\6"),"\t")
		-- resSext=string.split(kiko.regex(patternSENum,"i"):gsub(resTS[2],"\\2\t\\4\t\\6"),"\t")
		if resSext[1] ~= resTS[2] then
			-- 补全 TitleExt
			Array.extend(resSext,{"",""})
		else
			-- 含中文数字的集
			resSext=string.split(kiko.regex(patternSEZh,"i"):gsub(resTS[2],"\\2\t\\5\t\\7"),"\t")
			-- resSext=string.split(kiko.regex(patternSEZh,"i"):gsub(resTS[2],"\\2\t\\4\t\\6"),"\t")
			if resSext[1] ~= resTS[2] then
				Array.extend(resSext,{"",""})
			else
				-- Other unrecognizable results
				resSext={"","","",resTS[2],""}
            end
        end
		-- kiko.log("n\t\t"..resTS[2].."\t\t\t\t"..resTS[1])
	else
		-- 特别篇
        resTS=string.split(kiko.regex(patternSp,"i"):gsub(filename,"\\1\t\\3"),"\t")
		if resTS[1] ~= filename then
			while #resTS<2 do
				table.insert(resTS,"")
            end
			-- 获取季序数
			local sextSeasonNum=kiko.regex(patternSpSeason,"i"):gsub(resTS[2],[[\2]])
			if sextSeasonNum == resTS[2] then
				sextSeasonNum=""
            end
			-- 不实现识别 特别篇的集序数： 集序数没有统一标准，根据文件名 容易识别后相互覆盖，且无法判断是相关某集序数还是特别篇的序数
			-- local sextEpNum="" -- 集序数
			-- local sextEpExt="" -- 集序数拓展
			
            -- 获取集类型
			local sextEpType="" -- 集类型
            -- 特别篇 预告片 片头/OP 片尾/ED 其他
            if resTS[2] ~= kiko.regex(patternSpSp,"i"):gsub(resTS[2],[[\1\1]]) then
				sextEpType="SP"
            elseif resTS[2] ~= kiko.regex(patternSpTr,"i"):gsub(resTS[2],[[\1\1]]) then
				    sextEpType="TR"
            elseif resTS[2] ~= kiko.regex(patternSpOp,"i"):gsub(resTS[2],[[\1\1]]) then
                        sextEpType="OP"
            elseif resTS[2] ~= kiko.regex(patternSpEd,"i"):gsub(resTS[2],[[\1\1]]) then
                            sextEpType="ED"
            else
                sextEpType="OT"
            end
			resSext={sextSeasonNum,"","",resTS[2],sextEpType}
			-- kiko.log("s\t\t"..resTS[2].."\t\t\t\t"..resTS[1])
		else
			-- 仅标题
			resTS=string.split(kiko.regex(patternNum,"i"):gsub(filename,"\\1\t\\3"),"\t")
			while #resTS<2 do
				table.insert(resTS,"")
            end
			-- 获取 季序数
			local sextSeasonNum=kiko.regex(patternSpSeason,"i"):gsub(resTS[2],[[\2]])
			local sextEpType="" -- 如果有季序数 集类型为Others
			if sextSeasonNum == resTS[2] then
				sextSeasonNum=""
				sextEpType=""
            else sextEpType="OT"
            end
			-- 获取 集序数
			local sextEpNum=""
			sextEpNum=(kiko.regex([[^\d{1,}$]],"i")):gmatch(resTS[2])
            if(sextEpNum == nil) then sextEpNum=""
			else sextEpNum=sextEpNum()
            end

			resSext={sextSeasonNum,sextEpNum,"","",sextEpType}
			-- kiko.log("o\t\t"..resTS[2].."\t\t\t\t"..resTS[1])
        end
    end
	-- 处理数字
	for ri in pairs({1,2,3}) do
        if resSext[ri] == nil then resSext[ri]="" end
		if("" ~= resSext[ri]) then
            -- x十/十x -> x〇/一x
            -- resSext[ri]=(kiko.regex([[^(十)$]],"i")):gsub(resSext[ri],[[一〇]])
            resSext[ri]=(kiko.regex([[^(十)]],"i")):gsub(resSext[ri],[[一\1]])
            resSext[ri]=(kiko.regex([[(十)$]],"i")):gsub(resSext[ri],[[\1〇]])
            -- 中文数字->0-9

            string.gsub(resSext[ri],"十","")
            local zhnumToNum={["〇"]="0", ["零"]="0", ["一"]="1", ["二"]="2", ["三"]="3", ["四"]="4", ["五"]="5", ["六"]="6", ["七"]="7", ["八"]="8", ["九"]="9", ["十"]=""}
            for key, value in pairs(zhnumToNum or {}) do
                resSext[ri] = string.gsub(resSext[ri],key,value)
            end
            -- 除去开头的'0'
            resSext[ri]=(kiko.regex([[^(0{1,})]],"i")):gsub(resSext[ri],"")
        end
    end
	-- 提取标题
	local resT=resTS[1] -- TitleRaw
	-- 移除非标题内容的后缀
	resT=(kiko.regex("\\[([Mm]ovie|[Tt][Vv]|)\\]","i")):gsub(resT,"")
	-- 移除不在末尾的"[...]"
	resT=(kiko.regex([[\[[^\[\]\r\n\t]{1,}\](?![ \-\.\[\]\(\)]{0,}$)]],"i")):gsub(resT,"")
	-- 移除一些符号
	resT=(kiko.regex([[[《》_\-\.\[\]\(\)]{1,}]],"i")):gsub(resT," ")
	-- 移除开头/末尾/多余的空格
	resT=(kiko.regex([[ {1,}]],"i")):gsub(resT," ")
	resT=(kiko.regex([[(^ {1,}| {1,}$)]],"i")):gsub(resT,"")
	
	-- 获取识别结果
	table.insert(res,resT)
	Array.extend(res,resSext)
	
    -- 输出获取结果
    local tmpLogPrint=""
	-- tmpLogPrint=tmpLogPrint .."  "..#res.."\t"
    for ri = 2, #res, 1 do
		if res[ri] == "" then tmpLogPrint=tmpLogPrint.."▫".."\t"
		else tmpLogPrint=tmpLogPrint.. res[ri]..'\t' end
    end
    tmpLogPrint=tmpLogPrint..res[1]
	kiko.log("Finished getting media info RAW by filename.\n" ..
        "Season\tEp\tEpExt\tTitleExt\tEpType\tTitle:\n"..tmpLogPrint)
    return res
end
-- 读 xml 文本文件
-- path_xml:video.nfo|file_nfo -> kiko.xmlreader:xml_file_nfo
-- 拓展名 .nfo，内容为 .xml 格式
-- 文件来自 Emby 的本地服务器 在电影/剧集文件夹存储 从网站刮削出的信息。
function Path.readxmlfile(path_xml)

    -- local io_status =io.type(path_xml)
    -- if io_status ==nil then
    -- error("readxmlfile - Fail to get valid path of file < ".. path_xml .. ' >.')
    -- return nil;
    -- end
    local file_nfo = io.open(path_xml, 'r') -- 以只读方式 打开.xml文文本文件
    if file_nfo == nil then
        -- 文件打开错误
        kiko.log("[ERROR] readxmlfile - Fail to read file <" .. path_xml .. ' >.')
        error("readxmlfile - Fail to open file < " .. path_xml .. ' >.')
        return nil;
    end
    local xml_file_nfo = file_nfo:read("*a") -- 读文件，从当前位置读取整个文件
    if xml_file_nfo == nil then
        -- 读文件失败
        kiko.log("readxmlfile - Fail to read file < " .. path_xml .. ' | ' .. file_nfo .. ' >.')
        error("readxmlfile - Fail to read file < " .. path_xml .. ' | ' .. file_nfo .. ' >.')
        return nil;
    end
    file_nfo:close() -- 关闭文件
    local kxml_file_nfo = kiko.xmlreader(xml_file_nfo) -- 用kiko读.xml格式文本
    xml_file_nfo = nil -- 获取错误信息
    local err = kxml_file_nfo:error()
    if err ~= nil then
        -- 读.xml文本失败
        kiko.log("readxmlfile - Fail to read file < " .. path_xml .. ' | ' .. file_nfo .. ' >.')
        error("readxmlfile - Fail to read xml content < " .. path_xml .. ' | ' .. file_nfo .. ' >. ' .. err)
        return nil;
    end
    return kxml_file_nfo
end

-- query, namespace
function Kikoplus.httpgetMediaId(queryMe,namespace)
    if settings["api_key"] == "<<API_Key_Here>>" then
        kiko.log("Wrong api_key! 请在脚本设置中填写正确的TMDb的API密钥。")
        kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
        kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
    end
    local header = {["Accept"] = "application/json"}
    -- tmdb_id_media
    local err, replyMe = kiko.httpget(string.format(
        "http://api.themoviedb.org/3/" .. namespace), queryMe, header)

    if err ~= nil then
        kiko.log("[ERROR] TMDb.API.reply-"..namespace.."."..(queryMe.language or"")..".httpget: " .. err)
        if tostring(err) == ("Host requires authentication") then
            kiko.message("[错误] 请在脚本设置中填写正确的 `TMDb的API密钥`！",1|8)
            kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        end
        error(err)
    end
    local contentMe = replyMe["content"]
    local err, objMe = kiko.json2table(contentMe)
    if err ~= nil then
        kiko.log("[ERROR] TMDb.API.reply-"..namespace.."."..(queryMe.language or"")..".json2table: " .. err)
        error(err)
    end
    return objMe
end

-- 特殊字符转换 "&amp;" -> "&"  "&quot;" -> "\""
-- copy from & thanks to "..\\library\\bangumi.lua"
-- 在此可能用于媒体的标题名中的特殊符号，但是不知道需不需要、用不用得上。
function string.unescape(str)
    if type(str) ~= "string" then
        -- 非字符串
        return str
    end
    -- 替换符号
    str = string.gsub(str, '&lt;', '<')
    str = string.gsub(str, '&gt;', '>')
    str = string.gsub(str, '&quot;', '"')
    str = string.gsub(str, '&apos;', "'")
    str = string.gsub(str, '&#(%d+);', function(n)
                return utf8.char(n)
            end)
    str = string.gsub(str, '&#x(%x+);', function(n)
                return utf8.char(tonumber(n, 16))
            end)
    str = string.gsub(str, '&amp;', '&') -- Be sure to do this after all others
    return str
end
-- string.find reverse
-- 反向查找字符串首次出现
-- string:str  string:substr  number|int:ix -> number|int:字串首位索引
function string.findre(str, substr, ix)
    if ix < 0 then
        -- ix<0 即从后向前，换算为自前向后的序数
        ix = #str + ix + 1
    end
    -- 反转母串、子串查找，以实现
    local dstl, dstr = string.find(string.reverse(str), string.reverse(substr), #str - ix + 1, true)
    -- 返回子串出现在母串的左、右的序数
    return #str - dstl + 1, #str - dstr + 1
end
-- string.split("abc","b")
-- return: (table){} - 无匹配，返回 (table){input}
-- copy from & thanks to - https://blog.csdn.net/fightsyj/article/details/85057634
function string.split(input, delimiter)
    -- 分隔符nil，返回 (table){input}
    if type(delimiter) == nil then
        return {input}
    end
    -- 转换为string类型
    input = tostring(input)
    delimiter = tostring(delimiter)
    -- 分隔符空字符串，返回 (table){input}
    if (delimiter == "") then
        return {input}
    end

    -- 坐标；分割input后的(table)
    local pos, arr = 0, {}
    -- 从坐标每string.find()到一个匹配的分隔符，获取起止坐标
    for st, sp in function() return string.find(input, delimiter, pos, true) end do
        -- 插入 旧坐标到 分隔符开始坐标-1 的字符串
        table.insert(arr, string.sub(input, pos, st - 1))
        -- 更新坐标为 分隔符结束坐标+1
        pos = sp + 1
    end
    -- 插入剩余的字符串
    table.insert(arr, string.sub(input, pos))
    return arr
end
-- string.isEmpty():: nil->true | "" -> true
function string.isEmpty(input)
    if input==nil or tostring(input)==""
            or not (type(input)=="string" or type(input)=="number" or type(input)=="boolean") then
        return true
    else return false
    end
end

--获取默认集数，以秒数计算
function os.time2EpiodeNum()
return math.random(1,9)/10+(os.time()%900)+100
end

-- 打印 <table> 至 kiko
-- copy from & thanks to: https://blog.csdn.net/HQC17/article/details/52608464
-- { k = v }
Key_tts = "" -- 暂存来自上一级的键Key
function table.toStringLog(table, level)
    if (table == nil) then return "" end
    local indent = "" -- 打印的缩进
    local content = "" -- 暂存的字符串

    level = level or 1 -- 根级别 无缩进
    -- 按与根相差的级别缩进，每一个递归加一
    for i = 1, level do
        indent = indent .. "  "
    end

    local str = "" -- return的字符串
    -- 输出键名
    if Key_tts ~= "" then
        content = (indent .. Key_tts .. " " .. "=" .. " " .. "{")
        str = str .. content .. "\n"
        kiko.log(content)
    else
        content = (indent .. "{")
        str = str .. content .. "\n"
        kiko.log(content)
    end

    Key_tts = ""
    for k, v in pairs(table or {}) do
        if type(v) == "table" then
            -- <table>变量，递归
            Key_tts = k
            str = str .. table.toStringLog(v, level + 1)
        else
            -- 普通变量，直接打印
            local content = string.format("%s%s = %s", indent .. "  ", tostring(k), tostring(v or""))
            str = str .. content .. "\n"
            kiko.log(content)
        end
    end
    -- "}"
    str = str .. (indent .. "}") .. "\n"
    kiko.log(indent .. "}")
    return str
end
-- table 转 string - 把表转为字符串  （单向的转换，用于打印输出）
-- <table>table0 -> <string>:"(k)v, (k)[(k)v, (k)v], "
function table.toStringLine(table0)
    --
    if type(table0) ~= "table" then
        -- 排除非<table>类型
        return ""
    end
    local str = "" -- 要return的字符串
    for k, v in pairs(table0) do
        if type(v) ~= "table" then
            -- 普通变量，直接扩展字符串
            str = str .. "(" .. k .. ")" .. tostring(v or"") .. ", "
        else
            -- <table>变量，递归
            str = str .. "(" .. k .. ")" .. "[ " .. table.toStringLine(v) .. " ], "
        end
    end
    return str
end
-- table 转 多行的string - 把表转为多行（含\n）的字符串  （单向的转换，用于打印输出）
-- <table>table0 -> <string>:"[k]\t v,\n [ (k)v,\t (k)v ], \n"
function table.toStringBlock(table0, tabs)
    if tabs == nil then
        -- 根级别 无缩进
        tabs = 0
    end
    -- 排除非<table>类型
    if type(table0) ~= "table" then return "" end
    local str = "{\n" -- 要return的字符串
    tabs = tabs + 1
    for k, v in pairs(table0) do
        -- str=str..string.format("%10s",type(k).."-"..type(v)) -- [TEST]
        for i = 1, tabs, 1 do
            -- 按与根相差的级别缩进，每一个递归加一
            str = str .. "\t"
        end
        -- kiko.log(type(k).."  :  ".. tostring(k))
        if type(v) ~= "table" then
            -- 普通变量，直接扩展字符串
            str = str .. "[ " .. k .. " ] : \t" .. tostring(v or"") .. "\n"
        else
            -- <table>变量，递归
            str = str .. "[ " .. k .. " ] : \t" .. table.toStringBlock(v, tabs) .. "\n"
        end
    end
    for i = 2, tabs, 1 do
            -- 按与根相差的级别缩进，每一个递归加一
            str = str .. "\t"
    end
    return str .. "}"
end
-- 判断table是否为 nil 或 {}
-- copy from & thanks to - https://www.cnblogs.com/njucslzh/archive/2013/02/02/2886876.html
function table.isEmpty(ta)
    if ta == nil then
        return true
    end
    return _G.next( ta ) == nil
end
-- 深拷贝<table>，包含元表(?)，不考虑键key为<table>的情形
-- copy from & thanks to - https://blog.csdn.net/qq_36383623/article/details/104708468
function table.deepCopy(tb)
    if tb == nil or type(tb) ~= "table" then
        -- 排除非<table>的变量
        return nil
    end
    local copy = {}
    for k, v in pairs(tb) do
        if type(v) == 'table' then
            -- 值是<table>，递归复制<table>值
            copy[k] = table.deepCopy(v)
        else
            -- 普通值，直接赋值
            copy[k] = v
        end
    end
    -- local meta = table.deepCopy(getmetatable(tb))
    -- 设置元表。
    setmetatable(copy, table.deepCopy(getmetatable(tb)))
    return copy
end

-- array 转 string - 把表转为字符串  （单向的转换，用于打印输出）
-- <array>table0 -> <string>:"v, [(k)v, (k)v], "
function Array.toStringLine(table0)
    if type(table0) ~= "table" then
        -- 排除非<table>类型
        return ""
    end
    local str = "" -- 要return的字符串
    for k, v in pairs(table0) do
        if type(v) ~= "table" then
            -- 普通变量，直接扩展字符串
            str = str .. tostring(v or"") .. ", "
        else
            -- <table>变量，递归
            str = str .. "[ " .. table.toStringLine(v) .. " ], "
        end
    end
    return str
end
-- 将数组tb的所有的值 接续到数组ta的尾部，忽略tb中的键
function Array.extend(ta,tb)
    if ta == nil or type(ta) ~= "table" or tb == nil or type(tb) ~= "table" then
        -- 排除非<table>的变量
        return
    end
    for index, value in ipairs(tb) do
        table.insert(ta,value)
    end
end
-- 将数组tb(或其字段 str:tbField)中所有未出现在数组ta的值 乱序接续到ta的尾部，忽略tb中的键
function Array.extendUnique(ta,tb,tbField)
    if ta == nil or type(ta) ~= "table" or tb == nil or type(tb) ~= "table" then
        -- 排除非<table>的变量
        return
    end
    if type(tbField) ~= "string" and type(tbField) == "number" then
        tbField=nil
    end
    local isValueOf=false
    for _, vb in ipairs(tb or {}) do
        isValueOf=false
        if vb == nil then
            goto continue_Array_EU_f
        end
        if (tbField~=nil and vb[tbField] == nil) then
            goto continue_Array_EU_f
        end
        for _, va in ipairs(ta or {}) do
            if tbField==nil then
                if vb==va then
                    isValueOf=true
                    break
                end
            else
                if vb[tbField] == va then
                    isValueOf=true
                    break
                end
            end
        end
        if not isValueOf then
            if tbField==nil then
                table.insert(ta,vb)
            else
                table.insert(ta,vb[tbField])
            end
        end
        ::continue_Array_EU_f::
    end
end
