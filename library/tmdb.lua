-- DbScrape
----------------
-- 公共部分
-- 脚本信息
info = {
    ["name"] = "TMDb",
    ["id"] = "Kikyou.l.TMDb",
    ["desc"] = "The Movie Database (TMDb) 脚本 （测试中，不稳定） Edited by: kafovin \n"..
                "从 themoviedb.org 刮削影剧元数据，也可设置选择刮削Emby的本地元数据。",
["version"] = "0.1" -- 0.1.2.220223_alpha
}

-- 设置项
-- `key`为设置项的`key`，`value`是一个`table`。设置项值`value`的类型都是字符串。
-- 由于加载脚本后的特性，在脚本中，可以直接通过`settings["xxxx"]`获取设置项的值。
settings = {
    ["api_key"] = {
        ["title"] = "API - TMDb 的 API 密钥",
        ["default"] = "<<API_Key_Here>>",
        ["desc"] = "在`themoviedb.org`注册账号，并把个人设置中的API申请到的\n`API 密钥` (api key) 填入此项。（一般为一串字母数字）"
    },
    ["search_type"] = {
        ["title"] = "搜索 - 媒体类型",
        ["default"] = "multi",
        ["desc"] = "搜索的数据仅限此媒体类型。\n movie：电影； multi：电影/剧集； tv：剧集。", -- 丢弃`person`的演员搜索结果
        ["choices"] = "movie,multi,tv"
    },
    ["match_type"] = {
        ["title"] = "匹配 - 数据来源",
        ["default"] = "online_TMDb_filename",
        ["desc"] = "自动匹配本地媒体文件的数据来源。\n" ..
                    "local_Emby_nfo：来自Emby在刮削TMDb媒体后 在本地媒体文件同目录存储元数据的 .nfo格式文件(内含.xml格式文本)；\n" ..
                    "online_TMDb_filename：(不稳定) 从文件名模糊识别关键词，再用TMDb的API刮削元数据。 (*￣▽￣）", -- 丢弃`person`的演员搜索结果
        ["choices"] = "local_Emby_nfo,online_TMDb_filename"
    },
    ["match_priority"] = {
        ["title"] = "匹配 - 备用媒体类型",
        ["default"] = "multi",
        ["desc"] = "模糊匹配文件名信息时，类型待定的媒体以此类型匹配，仅适用于匹配来源为`online_TMDb_filename`的匹配操作。\n" ..
                    "此情况发生于文件名在描述 所有的电影、以及一些情况的剧集正篇或特别篇 的时候。\n" ..
                    -- "other：识别为`其他`类型的集（不同于本篇/特别篇），置于剧集特别篇或电影中。\n" ..
                    "movie：电影；multi：采用刮削时排序靠前的影/剧；tv：剧集；single：以对话框确定影/剧某一种 (不稳定)；",
        ["choices"] = "movie,multi,single,tv"
                    -- "movie,multi,tv,movie_other,multi_other,tv_other"
    },
    ["metadata_lang"] = {
        ["title"] = "元数据 - 语言",
        ["default"] = "zh-CN",
        ["desc"] = "搜索何种语言的资料作元数据，选择你需要的`语言编码-地区编码`。看着有很多语言，其实大部分都缺乏资料。\n" ..
                    "en-US：English(US)；fr-FR：Français(France)；ja-JP：日本語(日本)；ru-RU：Русский(Россия)\n" ..
                    "zh-CN：中文(中国)；zh-HK：中文(香港特區,中國)；zh-TW：中文(台灣省，中國)。\n" ..
                    "注意：再次关联导致标题改变时，弹幕仍然按照旧标题识别，请在`管理弹幕池`中手动复制弹幕到新标题。",
        ["choices"] = "af-ZA,ar-AE,ar-SA,be-BY,bg-BG,bn-BD,ca-ES,ch-GU,cn-CN,cs-CZ,cy-GB,da-DK" ..
                    ",de-AT,de-CH,de-DE,el-GR,en-AU,en-CA,en-GB,en-IE,en-NZ,en-US,eo-EO,es-ES,es-MX,et-EE" ..
                    ",eu-ES,fa-IR,fi-FI,fr-CA,fr-FR,ga-IE,gd-GB,gl-ES,he-IL,hi-IN,hr-HR,hu-HU,id-ID,it-IT" ..
                    ",ja-JP,ka-GE,kk-KZ,kn-IN,ko-KR,ky-KG,lt-LT,lv-LV,ml-IN,mr-IN,ms-MY,ms-SG,nb-NO,nl-BE" ..
                    ",nl-NL,no-NO,pa-IN,pl-PL,pt-BR,pt-PT,ro-RO,ru-RU,si-LK,sk-SK,sl-SI,sq-AL,sr-RS,sv-SE" ..
                    ",ta-IN,te-IN,th-TH,tl-PH,tr-TR,uk-UA,vi-VN,zh-CN,zh-HK,zh-SG,zh-TW,zu-ZA"
        -- ["choices"] = "ar-SA,de-DE,en-US,es-ES,fr-FR,it-IT,ja-JP,ko-KR,pt-PT,ru-RU,zh-CN,zh-HK,zh-TW",
        -- ["choices"] = "en-US,fr-FR,ja-JP,ru-RU,zh-CN,zh-HK,zh-TW",
    },
    ["metadata_info_origin_title"] = {
        ["title"] = "元数据 - 使用原语言标题",
        ["default"] = "0",
        ["desc"] = "元数据的标题是否使用原语言。\n0-不使用；1-使用。\n" ..
                    "注意：再次关联导致标题改变时，弹幕仍然按照旧标题识别，请在`管理弹幕池`中手动复制弹幕到新标题。",
        ["choices"] = "0,1"
    }
}

Metadata_search_page = 1 -- 元数据总共搜索页数。 默认： 1 页
Metadata_search_adult = false -- Choose whether to inlcude adult (pornography) content in the results when searching metadata. Default: false
Metadata_info_origin_title = true -- 是否使用源语言标题，在运行函数内更新值

-- 说明
-- 三目运算符 ((condition) and {trueCDo} or {falseCDo})[1] === (condition)?(trueCDo):(falseCDo)
-- (()and{}or{})[1]

-- (\{)(\[)("id"\]=)([0-9]{1,}?)(,\["name")(\]="[\S ^"]{1,}")(\})(,)
-- \2\4\6

-- 媒体所属的流派类型，tmdb的id编号->类型名 的对应
Media_genre = {
    [28] = "动作", [12] = "冒险", [16] = "动画", [35] = "喜剧", [80] = "犯罪", [99] = "纪录",
    [18] = "剧情", [10751] = "家庭", [14] = "奇幻", [36] = "历史", [27] = "恐怖",
    [10402] = "音乐", [9648] = "悬疑", [10749] = "爱情", [878] = "科幻", [10770] = "电视电影",
    [53] = "惊悚", [10752] = "战争", [37] = "西部", [10759] = "动作冒险", [10762] = "儿童",
    [10763] = "新闻", [10764] = "真人秀", [10765] = "Sci-Fi & Fantasy", [10766] = "肥皂剧",
    [10767] = "脱口秀", [10768] = "War & Politics",
}
-- TMDb图片配置
Image_tmdb = {
    ["prefix"]= "https://image.tmdb.org/t/p/", -- 网址前缀
    ["min_ix"]= 1, -- 尺寸索引
    ["mid_ix"]= 5,
    ["max_ix"]= 7,
    ["backdrop"]= {"w300","w300","w780","w780","w1280","w1280","original"}, -- 影/剧剧照
    ["logo"]= {"w45","w92","w154","w185","w300","w500","original"}, -- /company/id - /network/id - 出品公司/电视网标志
    ["poster"]= {"w92","w154","w185","w342","w500","w780","original"}, -- 影/剧海报
    ["profile"]= {"w45","w45","w185","w185","h632","h632","original"}, -- /person/id 演员肖像
    ["still"]= {"w92","w92","w185","w185","w300","w300","original"}, -- /tv/id/season/sNum/episode/eNum 单集剧照
}
--[[
-- 媒体信息<table>
Anime_data = {
    ["media_title"] = unescape(mediai["media_title"]) or unescape(mediai["media_name"]),		-- 标题
    ["original_title"] = unescape(mediai["original_title"]) or unescape(mediai["original_name"]),-- 原始语言标题
    ["media_id"] = tostring(mediai["id"]),			-- 媒体的 tmdb id
    ["media_imdbid"],			-- 媒体的 imdb id
    ["media_type"] = mediai["media_type"],			-- 媒体类型 movie tv person
    ["genre_ids"] = mediai["genre_ids"],			-- 流派类型的编号 table/Array
    ["genre_names"],			-- 流派类型 table/Array
    ["release_date"] = mediai["release_date"] or mediai["air_date"] or mediai["first_air_date"], -- 首映/本季首播/发行日期
    ["original_language"] = mediai["original_language"], -- 原始语言
    ["origin_country"] = mediai["origin_country"],	-- 原始首映/首播国家地区
    ["origin_company"],	-- 原始首映/首播国家地区
    ["overview"] = mediai["overview"],				-- 剧情梗概
    ["vote_average"] = mediai["vote_average"],		-- 平均tmdb评分
    ["person_staff"],			-- "job1:name1;job2;name2;..."
    ["person_character"],		-- { ["name"]=string,   --人物名称 ["actor"]=string,  --演员名称 ["link"]=string,   --人物资料页URL  ["imgurl"]=string --人物图片URL }
    ["rate_mpaa"],				-- MPAA分级
    ["file_path"],				-- 文件目录

-- ["season_episode"],			-- 某季的集数 {{season_number,episode_count},{0,10}，{1,16}，{2,11}}
    ["season_count"],			-- 剧集的 总季数 - 含 S00/Specials/特别篇/S05/Season 5/第 5 季
    ["season_number"],			-- 本季的 季序数 /第几季 - 0-specials
    ["season_title"],			-- 本季的 季名称 - "季 2" "Season 2" "Specials"
    ["episode_count"],			-- 本季的 总集数
    ["tv_first_air_date"] = ["first_air_date"],		-- 剧集首播/发行日期
    
    -- Image_tmdb.prefix..Image_tmdb.poster[Image_tmdb.max_ix] .. data["image_path"]
    ["poster_path"] = mediai["poster_path"] or tvSeasonsIx["poster_path"],		-- 海报图片 电影/剧集某季
    ["tv_poster_path"] = mediai["poster_path"],  -- 海报图片 剧集
    ["backdrop_path"] = mediai["backdrop_path"],	-- 背景图片 电影/剧集
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

    return searchMediaInfo(keyword,settings_search_type)
end
function searchMediaInfo(keyword, settings_search_type)
    -- 需要注意的是，除了下面定义的AnimeLite结构，还可以增加一项eps，类型为Array[EpInfo]，包含动画的剧集列表。
    -- httpget( query, header ) -> json:reply
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
        kiko.log("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
        kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
        error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
    end
    -- 获取 http get 请求 - 查询特定媒体类型 特定关键字 媒体信息的 搜索结果列表
    if(settings_search_type ~= "movie" and settings_search_type ~= "tv") then
        settings_search_type="multi"
    end
    local err, reply = kiko.httpget(string.format("http://api.themoviedb.org/3/search/" .. settings_search_type),
        query, header)
    if err ~= nil then
        kiko.log("[ERROR] TMDb.API.reply-search."..settings_search_type..".httpget: ".. err)
        if tostring(err) == ("Host requires authentication") then
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
    for _, mediai in pairs(obj['results']) do
        if (mediai["media_type"] ~= 'tv' and mediai["media_type"] ~= 'movie' and settings_search_type == "multi") then
            -- 跳过对 演员 的搜索 - 跳过 person
            goto continue_search_a
        end
        -- 显示的媒体标题 title/name
        local mediaName
        if (Metadata_info_origin_title) then
            mediaName = unescape(mediai["original_title"] or mediai["original_name"])
        else
            mediaName = unescape(mediai["title"] or mediai["name"])
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
        data["media_title"] = unescape(mediai["title"]) or unescape(mediai["name"]) -- 标题
        data["original_title"] = unescape(mediai["original_title"]) or unescape(mediai["original_name"]) -- 原始语言标题
        data["media_id"] = string.format("%d", mediai["id"]) -- 媒体的 tmdb id
        data["release_date"] = mediai["release_date"] or mediai["first_air_date"] -- 首映/首播/发行日期
        data["original_language"] = mediai["original_language"] -- 原始语言
        data["origin_country"] = mediai["origin_country"] -- 原始首映/首播国家地区
        data["overview"] = string.gsub(string.gsub(mediai["overview"], "\n\n", "\n"), "\r\n\r\n", "\r\n") -- 剧情梗概
        data["vote_average"] = mediai["vote_average"] -- 平均tmdb评分
        -- genre_ids -> genre_names
        data["genre_names"] = {} -- 流派类型 table/Array
        -- 流派类型id ->流派类型名称
        for key, value in pairs(mediai["genre_ids"]) do -- key-index value-id
            local genreIdIn = false -- genre_ids.value-id in Media_genre
            for k, v in pairs(Media_genre) do
                if k == value then
                    genreIdIn = true
                end
            end
            if genreIdIn then
                data["genre_names"][key] = Media_genre[value]
            end
        end
        -- 图片链接
        -- 海报图片
        if (mediai["poster_path"] ~= nil and mediai["poster_path"] ~= "") then
            data["poster_path"] = mediai["poster_path"]
        else
            data["poster_path"] = ""
        end
        -- 背景图片
        if (mediai["backdrop_path"] ~= nil and mediai["backdrop_path"] ~= "") then
            data["backdrop_path"] = mediai["backdrop_path"]
        else
            data["backdrop_path"] = ""
        end

        --[[
        -- 国家地区
        data["origin_country"] = {}
        if tvSeasonsIx["origin_country"] ~= nil then
            for value in tvSeasonsIx["origin_country"] do
                -- data["origin_country"].insert(value["name"])
                data["origin_country"].insert(value)
            end
        end
        if tvSeasonsIx["production_countries"] ~= nil then
            for _, value in pairs(tvSeasonsIx["production_countries"]) do
                -- data["origin_country"].insert(value["name"])
                data["origin_country"].insert(value["iso_3166_1"])
            end
        end
        --出品公司
        data["origin_company"] = {}
        if tvSeasonsIx["networks"] ~= nil then
            for value in pairs(tvSeasonsIx["networks"]) do
                -- data["origin_country"].insert(value["name"])
                data["origin_country"].insert(value["name"])
            end
        end
        if tvSeasonsIx["production_companies"] ~= nil then
            for _, value in pairs(tvSeasonsIx["production_companies"]) do
                -- data["origin_country"].insert(value["name"])
                data["origin_country"].insert(value["name"])
            end
        end
        ]]--
        -- season_number, episode_count,
        if data["media_type"] == "movie" then
            -- movie - 此条搜索结果是电影
            -- 把电影视为单集电视剧
            data["season_number"] = 1
            data["episode_count"] = 1
            data["season_count"] = 1
            data["season_title"] = data["original_title"]
            local media_data_json
            -- 把媒体信息<table>转为json的字符串
            err, media_data_json = kiko.table2json(table.deepCopy(data))
            if err ~= nil then
                kiko.log(string.format("[ERROR] table2json: %s", err))
            end
            -- kiko.log(string.format("[INFO]  mediaName: [ %s ], data:\n%s", mediaNameSeason, tableToStringLines(data)));

            -- 从 媒体信息的发行日期/年份 获取年份字符串，加到电影名后，以防重名导致kiko数据库错误。形如 "电影名 (2010)"
            -- get "Movie Name (YEAR)"
            if data["release_date"] ~= nil and data["release_date"] ~= "" then
                mediaName = mediaName .. string.format(' (%s)', string.sub(data["release_date"], 1, 4))
            end
            -- 插入搜索条目table到列表 mediais
            table.insert(mediais, {
                ["name"] = mediaName,
                ["data"] = media_data_json,
                ["extra"] = "类型：" .. data["media_type"] .. "  |  首映：" ..
                    ((data["release_date"] or "") .. " " .. (data["first_air_date"] or "")) .. "  |  语言：" ..
                    (data["original_language"] or "") .. "  " .. arrayToString(data["origin_country"]) ..
                    "\r\n简介：" .. (data["overview"] or ""),
                -- ["extra"] = "  " .. data["media_type"] .. "  |  " ..
                --     ((data["release_date"] or "") .. " " .. (data["first_air_date"] or "")) .. "  |  " ..
                --     (data["original_language"] or "") .. "-" .. arrayToString(data["origin_country"]) ..
                --     "\r\n" .. (data["overview"] or "")
                -- ["eps"]=epList
                ["scriptId"] = "Kikyou.l.TMDb",
                ["media_type"] = data["media_type"],
            })
        elseif data["media_type"] == "tv" then
            -- tv - 此条搜索结果是剧集
            -- http get 请求 参数
            local queryTv = {
                ["api_key"] = settings["api_key"],
                ["language"] = settings["metadata_lang"]
            }
            if settings["api_key"] == "<<API_Key_Here>>" then
                kiko.log("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
                kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
                error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
            end
            -- 获取 http get 请求 - 查询 特定tmdbid的剧集的 媒体信息
            local err, replyTv = kiko.httpget(string.format(
                "http://api.themoviedb.org/3/" .. data["media_type"] .. "/" .. data["media_id"]), queryTv, header)

            if err ~= nil then
                kiko.log("[ERROR] TMDb.API.reply-search."..data["media_type"] .. ".id.httpget: " .. err)
                if tostring(err) == ("Host requires authentication") then
                    kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
                end
                error(err)
            end
            -- json:reply -> Table:obj
            local contentTv = replyTv["content"]
            local err, objTv = kiko.json2table(contentTv)
            if err ~= nil then
                kiko.log("[ERROR] TMDb.API.reply-search."..data["media_type"] .. ".id.json2table: " .. err)
                error(err)
            end

            data["season_count"] = #(objTv["seasons"]) -- 季总数
            -- 去除剧情介绍多余的空行
            if objTv["tagline"] ~= "" then
                data["overview"] = string.gsub(string.gsub(objTv["tagline"], "\n\n", "\n"), "\r\n\r\n", "\r\n") ..
                    "\n" .. data["overview"]
            end

            -- Table:obj -> Array:mediai
            -- local tvSeasonsIxs = {}
            data["tv_first_air_date"] = data["release_date"] -- 发行日期
            data["tv_poster_path"] = data["poster_path"] -- 海报链接
            local data_overview = data["overview"] -- 剧情介绍
            for _, tvSeasonsIx in pairs(objTv['seasons']) do
                local mediaNameSeason = mediaName -- 形如"剧集名"
                data["release_date"] = tvSeasonsIx["air_date"] -- 首播日期
                data["season_title"] = tvSeasonsIx["name"] -- 季标题
                if tvSeasonsIx["overview"] ~= "" then
                    -- 剧情简介附上 季剧情简介 （去除空行）
                    data["overview"] = string.gsub(string.gsub(tvSeasonsIx["overview"], "\n\n", "\n"), "\r\n\r\n",
                        "\r\n") .. "\n" .. data_overview
                else
                    data["overview"] = data_overview
                end
                -- 海报图片链接
                if (tvSeasonsIx["poster_path"] ~= nil and tvSeasonsIx["poster_path"] ~= "") then
                    data["poster_path"] = tvSeasonsIx["poster_path"]
                elseif (data["tv_poster_path"] ~= nil and data["tv_poster_path"] ~= "") then
                    data["poster_path"] = data["tv_poster_path"]
                else
                    data["poster_path"] = ""
                end

                data["season_number"] = math.floor(tvSeasonsIx["season_number"]) -- 季序数
                data["episode_count"] = math.floor(tvSeasonsIx["episode_count"]) -- 集总数（本季节）

                local seasonNameNormal -- 判断是否为普通的 季名称 S00/Specials/特别篇/S05/Season 5/第 5 季
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
                            mediaNameSeason = mediaNameSeason .. string.format(' 第%d季', data["season_number"])
                        else
                            mediaNameSeason = mediaNameSeason .. ' 特别篇'
                        end
                    else
                        if tonumber(data["season_number"]) ~= 0 then
                            mediaNameSeason = mediaNameSeason .. string.format(' S%02d', data["season_number"])
                        else
                            mediaNameSeason = mediaNameSeason .. ' Specials'
                        end
                    end
                else
                    mediaNameSeason = mediaNameSeason .. " " .. data["season_title"]
                end
                -- 从 媒体信息的发行日期/年份 获取年份字符串，加到电影名后，以防重名导致kiko数据库错误。形如 "剧集名 第2季 (2010)"
                if data["release_date"] ~= nil and data["release_date"] ~= "" then
                    mediaNameSeason = mediaNameSeason .. string.format(' (%s)', string.sub(data["release_date"], 1, 4))
                end

                -- 把媒体信息<table>转为json的字符串
                local media_data_json
                err, media_data_json = kiko.table2json(table.deepCopy(data))
                if err ~= nil then
                    kiko.log(string.format("[ERROR] table2json: %s", err))
                end
                -- kiko.log(string.format("[INFO]  mediaName: [ %s ], data:\n%s", mediaNameSeason, tableToStringLines(data)));
                local seasonTextNormal = ""
                if data["season_number"] ~= 0 then
                    seasonTextNormal = string.format("第%02d季", data["season_number"] or "")
                else
                    seasonTextNormal = "特别篇"
                end

                -- 插入搜索条目table到列表 mediais
                table.insert(mediais, {
                    ["name"] = mediaNameSeason,
                    ["data"] = media_data_json,
                    ["extra"] = "类型：" .. data["media_type"] .. "          |  首播：" ..
                        ((data["release_date"] or "") .. " " .. (data["first_air_date"] or "")) ..
                        "  |  语言：" .. (data["original_language"] or "") .. "  " .. arrayToString(data["origin_country"]) ..
                        "  |  " .. seasonTextNormal .. string.format(" (共%2d季) ", data["season_count"] or "") ..
                        "  |  集数：" .. string.format("%d", data["episode_count"] or "") ..
                        "\r\n简介：" .. (data["overview"] or ""),
                    -- ["extra"] = "  " .. data["media_type"] .. " | " ..
                    --     (data["release_date"] or tvSeasonsIx["air_date"] or data["first_air_date"] or "") .. " | " ..
                    --     (data["original_language"] or "") .. "-" .. tableToString(data["origin_country"]) ..
                    --     "\r\n" .. (data["overview"] or "")
                    -- ["eps"]=epList
                    ["scriptId"] = "Kikyou.l.TMDb",
                    ["media_type"] = data["media_type"],
                    ["season_number"] = data["season_number"],
                })
            end
        end

        ::continue_search_a::
    end
    kiko.log("[INFO]  Finished searching <" .. keyword .. "> with " .. #(obj['results']) .. " results")
    -- kiko.log("[INFO]  Reults:\t" .. tableToStringLines(mediais))
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
            kiko.log("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
            kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
            error("Wrong api_key! 请在脚本设置中填写正确的API密钥。")
        end
        -- 获取 http get 请求 - 查询 特定tmdbid的剧集的 特定季序数的 媒体信息
        local err, reply = kiko.httpget(string.format("http://api.themoviedb.org/3/tv/" .. anime_data["media_id"] ..
                                                "/season/" .. (anime_data["season_number"])), query, header)

        if err ~= nil then
            kiko.log("[ERROR] TMDb.API.reply-getep.tv.id.season.httpget: " .. err)
            if tostring(err) == ("Host requires authentication") then
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
        for _, seasonEpsIx in pairs(objS['episodes']) do

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

        --[[
        -- 默认集数命名 [S01E02] - Season 1 Episode 2
        for i = 1, math.floor(anime_data["episode_count"]), 1 do
            epName, epIndex, epType = nil, nil, nil
            epName = string.format("S%02dE%02d", anime_data["season_number"], i)
            epIndex = i
            if anime_data["season_number"] == 0 then
                epType = 2
            else
                epType = 1
            end
            table.insert(eps, {
                ["name"] = epName,
                ["index"] = epIndex,
                ["type"] = epType
            })
            -- kiko.log(string.format("[INFO]  TV [%s] on Episode %d :[%s] %s", anime_data["original_title"] ..string.format("S%02dE%02d", anime_data["season_number"], i), epIndex, epType, epName))
        end
        ]] --
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
-- ]] --

-- 获取动画详细信息
-- anime： AnimeLite
-- 返回：Anime
function detail(anime)
    kiko.log("[INFO]  Getting detail of <" .. anime["name"] .. ">")
    -- tableToStringPrint(anime) -- kiko.log()
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
    -- tableToStringPrint(anime_data) -- kiko.log("")

    local titleTmp = "" -- 形如 "media_title (original_title)"
    if anime_data["media_title"] then
        titleTmp = titleTmp .. "\n" .. anime_data["media_title"]
        if anime_data["original_title"] then
            titleTmp = titleTmp .. " (" .. anime_data["original_title"] .. ")"
        end
    else
        if anime_data["original_title"] then
            titleTmp = titleTmp .. "\n" .. anime_data["original_title"]
        end
    end
    -- 从AmimeLite:anime["data"]读取详细信息
    local animePlus = {
        ["name"] = anime["name"],
        ["data"] = anime["data"],
        ["url"] = ((anime_data["media_type"]) and {"https://www.themoviedb.org/" ..
                 anime_data["media_type"] .. "/" .. anime_data["media_id"]} or {""})[1], -- 条目页面URL
        ["desc"] = anime_data["overview"] .. titleTmp, -- 描述
        ["airdate"] = ((anime_data["release_date"]) and {
                 anime_data["release_date"]} or {anime_data["tv_first_air_date"]})[1] or "", -- 发行日期，格式为yyyy-mm-dd 
        ["epcount"] = anime_data["episode_count"], -- 分集数
        ["coverurl"] = Image_tmdb.prefix..Image_tmdb.poster[Image_tmdb.max_ix] .. anime_data["poster_path"], -- 封面图URL
        ["staff"] = anime_data["person_staff"], -- staff - "job1:staff1;job2:staff2;..."
        ["crt"] = anime_data["person_character"], -- 人物
        ["scriptId"] = "Kikyou.l.TMDb"
    }
    if anime_data["media_type"] == "movie" then
        kiko.log("[INFO]  Finished getting detail of < " .. anime_data["media_title"] ..
                     " (" .. anime_data["original_title"] .. ") >")

    elseif anime_data["media_type"] == "tv" then
        kiko.log("[INFO]  Finished getting detail of < " .. anime_data["media_title"] .. " (" ..
                     anime_data["original_title"] .. ") " .. string.format("S%02d", anime_data["season_number"]) .. ">")
    end
    -- kiko.log("[INFO]  Anime = " .. tableToStringLines(animePlus))
    return animePlus
end

-- 获取标签
-- anime： Anime
-- 返回： Array[string]，Tag列表
function gettags(anime)
    -- KikoPlay支持多级Tag，用"/"分隔，你可以返回类似“动画制作/A1-Pictures”这样的标签
    kiko.log("[INFO]  Starting getting tags of" .. anime["name"])
    -- tableToStringPrint(anime) -- kiko.log()
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
    -- tableToStringPrint(anime_data) -- kiko.log("")
    local mtag = {} -- 标签数组
    local genre_name_tmp -- 暂存字符串
    -- 添加 流派类型 至标签
    for _, value in pairs(anime_data["genre_names"]) do
        if (value ~= nil) then
            genre_name_tmp = value .. ""
            table.insert(mtag, "流派/"..genre_name_tmp)
        end
    end
    -- 添加 媒体类型 至标签
    if anime_data["media_type"] == "movie" then
        table.insert(mtag, "媒体类型/电影")

    elseif anime_data["media_type"] == "tv" then
        table.insert(mtag, "媒体类型/剧集")
    else
        table.insert(mtag, "媒体类型/其他")
    end
    -- 添加 出品公司 至标签
    if anime_data["origin_company"] ~= nil then
        for _, value in pairs(anime_data["origin_company"]) do
            if (value ~= nil) then
                genre_name_tmp = value .. ""
                table.insert(mtag, "出品方/"..genre_name_tmp)
            end
        end

    end
    -- 添加 国家 至标签
    if anime_data["origin_country"] ~= nil then
        for _, value in pairs(anime_data["origin_country"]) do
            if (value ~= nil) then
                genre_name_tmp = value .. ""
                table.insert(mtag, "地区/"..genre_name_tmp)
            end
        end

    end
    -- 添加 原语言 至标签
    if anime_data["original_language"] ~= nil then
        table.insert(mtag, "语言/"..anime_data["original_language"])

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

    --
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
        local path_folder_sign, _ = stringfindre(path, "/", -1) -- 路径索引 父文件夹尾'/' path/to[/]video.ext
        local path_file_name = string.sub(path, path_folder_sign + 1) -- 媒体文件名称.拓展名 - video.ext
        local resMirbf=getMediaInfoRawByFilename(path_file_name)
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
                ["tip"] = "<" .. mTitle .. ">： 确认->电影； 取消->剧集。",
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
                kiko.message("无法找到电影 <"..mTitle..">。", 1|8)
                return {["success"] = false, ["anime"] = {["name"]=mTitle}, ["ep"] = {},}
            end
            mediainfo=resultSearch[mPriority]
            
            -- epInfo
            if mIsSp == false then
                local mEpTmp=1
                resultGetep = getep(mediainfo)
                if #resultGetep < mEpTmp then
                    kiko.log("[ERROR] Failed to find movie <"..mTitle..">。")
                    kiko.message("无法找到电影 <"..mTitle..">。", 1|8)
                    return {["success"] = false, ["anime"] = {["name"]=mTitle}, ["ep"] = {},}
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
                                (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。", 1|8)
                    return {["success"] = false, ["anime"] = mediainfo, ["ep"] = {},}
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
            for _, value in ipairs(resultSearch) do
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
                kiko.message("无法找到剧集 <"..mTitle.."> ".. (((mSeason=="")and{""}or{"的 <第"..mSeason.."季>"})[1]).."。", 1|8)
                return {["success"] = false, ["anime"] = {["name"]=mTitle}, ["ep"] = {},}
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
                for _, value in ipairs(resultGetep) do
                    if value["index"] == mEpTmp or tostring(value["index"]) == tostring(mEpTmp) then
                        epinfo=value
                        break
                    end
                end
                if table.isEmpty(epinfo) then
                    kiko.log("[ERROR] Failed to find tv <"..mTitle..(((mSeason=="")and{""}or{" Season"..mSeason})[1])..">" ..
                                (((mEp=="")and{""}or{" <Episode "..mEp..">"})[1]).."。")
                    kiko.message("无法找到剧集 <"..mTitle..(((mSeason=="")and{""}or{" 第"..mSeason.."季"})[1])..">" ..
                                (((mEp=="")and{""}or{"的 <第"..mEp.."集>"})[1]).."。", 1|8)
                    return {["success"] = false, ["anime"] = mediainfo, ["ep"] = {["index"] = math.floor(tonumber(mEpTmp))},}
                end
            else
                epinfo={
                    ["name"] = mTitleX,
                    ["index"] = ((mEp == "")and{nil}or{ math.floor(tonumber(mEp)) })[1],
                    ["type"] = ((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType]})[1],
                }
                if epinfo["index"] == nil then
                    local tmpLogStr = 
                    kiko.log("[ERROR] Failed to find  <"..mTitle..(((mSeason=="")and{""}or{" Season "..mSeason})[1]).."> "..
                                " in " .. epTypeName[epinfo["type"]] .. (((mEp=="")and{""}or{string.format(" %02d",mEp)})[1])..
                                (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。")
                    kiko.message("无法找到剧集 <"..mTitle..(((mSeason=="")and{""}or{" 第"..mSeason.."季"})[1]).."> "..
                                "的 " .. epTypeName[epinfo["type"]] .. (((mEp=="")and{""}or{string.format("%02d",mEp)})[1])..
                                (((mTitleX=="")and{""}or{" <"..mTitleX..">"})[1]).. "。", 1|8)
                    return {["success"] = false, ["anime"] = mediainfo,
                            ["ep"] = { ["type"]=((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType]})[1]},}
                end
            end
        else
            -- mediaInfo
            resultSearch = searchMediaInfo(mTitle,"multi")
            if #resultSearch < mPriority then
                kiko.log("[ERROR] Failed to find media <"..mTitle..">。")
                kiko.message("无法找到媒体 <"..mTitle..">。", 1|8)
                return {["success"] = false, ["anime"] = {["name"]=mTitle}, ["ep"] = {},}
            end
            local mSeasonTv = ""
            for _, value in ipairs(resultSearch) do
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
                    kiko.message("无法找到剧集 <"..mTitle.."> ".. (((mSeason=="")and{""}or{"的 <第"..mSeason.."季>"})[1]).."。", 1|8)
                else
                    kiko.log("[ERROR] Failed to find media <"..mTitle..">。")
                    kiko.message("无法找到媒体 <"..mTitle..">。", 1|8)
                end
                return {["success"] = false, ["anime"] = {["name"]=mTitle}, ["ep"] = {["index"] = math.floor(tonumber(mEpTmp))},}
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
                    for _, value in ipairs(resultGetep) do
                        if value["index"] == mEpTmp or tostring(value["index"]) == tostring(mEpTmp) then
                            epinfo=value
                            break
                        end
                    end
                    if table.isEmpty(epinfo) then
                        kiko.log("[ERROR] Failed to find tv <"..mTitle..(((mSeason=="")and{""}or{" Season "..mSeason})[1])..">" ..
                                    (((mEp=="")and{""}or{" <Episode"..mEp..">"})[1]).."。")
                        kiko.message("无法找到剧集 <"..mTitle..(((mSeason=="")and{""}or{" 第"..mSeason.."季"})[1])..">" ..
                                    (((mEp=="")and{""}or{"的 <第"..mEp.."集>"})[1]).."。", 1|8)
                        return {["success"] = false, ["anime"] = mediainfo, ["ep"] = {},}
                    end
                elseif mType == "movie" then
                    mEp=1
                    resultGetep = getep(mediainfo)
                    if #resultGetep < mEp then
                        kiko.log("[ERROR] Failed to find movie <"..mTitle..">。")
                        kiko.message("无法找到电影 <"..mTitle..">。", 1|8)
                        return {["success"] = false, ["anime"] = mediainfo, ["ep"] = {},}
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
                        kiko.message("无法找到电影 <"..mTitle.."> " .. tmpLogStr, 1|8)
                    elseif epinfo["type"] == "tv" then
                        kiko.log("[ERROR] Failed to find tv <"..mTitle..(((mSeason=="")and{""}or{" Season "..mSeason})[1]).."> ".. tmpLogStr)
                        kiko.message("无法找到剧集 <"..mTitle..(((mSeason=="")and{""}or{" 第"..mSeason.."季"})[1]).."> ".. tmpLogStr, 1|8)
                    else
                        kiko.log("[ERROR] Failed to find media <"..mTitle.."> " .. tmpLogStr)
                        kiko.message("无法找到媒体 <"..mTitle.."> " .. tmpLogStr, 1|8)
                    end
                    return {["success"] = false, ["anime"] = mediainfo,
                            ["ep"] = { ["type"]=((mEpType == "")and{epTypeMap["OT"]}or{epTypeMap[mEpType]})[1]},}
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
        local path_file_sign, _ = stringfindre(path, ".", -1) -- 路径索引 文件拓展名前'.' path/to/video[.]ext
        local path_folder_sign, _ = stringfindre(path, "/", -1) -- 路径索引 父文件夹尾'/' path/to[/]video.ext
        -- kiko.log('TEST  - '..path_file_sign)
        -- kiko.log('TEST  - '..path_folder_sign)
        local path_file_name = string.sub(path, path_folder_sign + 1,
                                        path_file_sign - 1) -- 媒体文件名称 不含拓展名 - video
        local path_folder_l = string.sub(path, 1, path_folder_sign) -- 父文件夹路径 含结尾'/' -  tv/season/   movie/
        path_folder_sign, _ = stringfindre(path, "/", path_folder_sign - 1) -- 路径索引 父父文件夹尾'/' path[/]to/video.ext
        local path_folder_lf = string.sub(path, 1, path_folder_sign) -- 父父文件夹路径 含结尾'/' -  tv/

        -- 读取媒体信息.nfo文件 (.xml文本)
        local xml_file_path = path_folder_l .. path_file_name .. '.nfo' -- 媒体信息文档全路径 path/to/video.nfo 文本为 .xml 格式
        local xml_v_nfo = readxmlfile(xml_file_path) -- 获取媒体信息文档
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
        mdata["file_path"] = path -- 文件路径
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
                    mdata["backdrop_path"] = "" .. path_folder_l .. "fanart.jpg" -- Emby存储的电影 背景路径
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
                                mdata["overview"] = string.gsub(string.gsub(tmpElem, "\n\n", "\n"), "\r\n\r\n", "\r\n") -- 去除空行
                            elseif xml_v_nfo:name() == "director" then
                                -- "导演"标签
                                if mdata["person_staff"] == nil then
                                    mdata["person_staff"] = ''
                                end
                                -- 处理职员表字符串信息
                                mdata["person_staff"] = mdata["person_staff"] .. 'Director:' .. tmpElem .. ';'
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
                                if mdata["origin_company"] == nil then
                                    mdata["origin_company"] = {}
                                end
                                table.insert(mdata["origin_company"], tmpElem)
                            elseif xml_v_nfo:name() == "actor" then
                                -- "演员"标签组
                                if mdata["person_character"] == nil then
                                    -- 初始化table
                                    mdata["person_character"] = {}
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
                                table.insert(mdata["person_character"], {
                                    ["name"] = cname, -- 人物名称
                                    ["actor"] = cactor, -- 演员名称
                                    ["link"] = clink -- 人物资料页URL
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
                                if mdata["person_staff"] == nil then
                                    mdata["person_staff"] = ''
                                end
                                -- 处理职员表字符串信息
                                mdata["person_staff"] = mdata["person_staff"] .. 'Director:' .. tmpElem .. ';'
                            elseif xml_v_nfo:name() == "actor" then
                                -- xml_v_nfo:readnext()
                                -- ignore actors
                                -- while xml_v_nfo:name() ~= "actor" or not (not xml_v_nfo:startelem()) do
                                --     -- kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>'..tmpElem)
                                --     xml_v_nfo:readnext()

                                -- "演员"标签组
                                if mdata["person_character"] == nil then
                                    mdata["person_character"] = {}
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
                                            clink = "https://www.themoviedb.org/person/" .. tmpElem
                                            -- elseif xml_v_nfo:name()=="content" then
                                            --     cimgurl = tmpElem
                                        end
                                        -- kiko.log('TEST  - Actor tag <'..xml_v_nfo:name()..'>.'..tmpElem)
                                    end
                                    -- 读取下一个标签
                                    xml_v_nfo:readnext()
                                end
                                -- 向演员信息<table>插入一个演员的信息
                                table.insert(mdata["person_character"], {
                                    ["name"] = cname, -- 人物名称
                                    ["actor"] = cactor, -- 演员名称
                                    ["link"] = clink -- 人物资料页URL
                                    -- ["imgurl"]=cimgurl,  --人物图片URL
                                })
                                -- kiko.log(tableToString(mdata["person_character"]))
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
                    local xml_ts_nfo = readxmlfile(xml_ts_path) -- 读取.xml格式文本
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
                                mdata["overview"] = string.gsub(string.gsub(tmpElem, "\n\n", "\n"), "\r\n\r\n", "\r\n") -- 去除空行
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
                                if mdata["person_character"] == nil then
                                    mdata["person_character"] = {}
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
                                table.insert(mdata["person_character"], {
                                    ["name"] = cname, -- 人物名称
                                    ["actor"] = cactor, -- 演员名称
                                    ["link"] = clink -- 人物资料页URL
                                    -- ["imgurl"]=cimgurl,  --人物图片URL
                                })
                                -- kiko.log(tableToString(mdata["person_character"]))
                            end
                            -- kiko.log('[INFO]  Reading tag <' .. xml_ts_nfo:name() .. '>' .. tmpElem)
                        end
                        -- 读取下一个标签
                        xml_ts_nfo:readnext()
                    end
                    xml_ts_nfo:clear()

                    kiko.log('[INFO]  \t Reading tv nfo')
                    local xml_tv_path = path_folder_lf .. 'tvshow.nfo' -- 单季信息.nfo文件路径
                    local xml_tv_nfo = readxmlfile(xml_tv_path) -- 读取.xml格式文本
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
                                mdata["overview"] = string.gsub(string.gsub(mdata["overview"],
                                     "\n\n", "\n"), "\r\n\r\n", "\r\n") .. "\r\n" -- 去除空行
                                else
                                    mdata["overview"] = ""
                                end
                            mdata["overview"] = mdata["overview"] .. string.gsub(string.gsub(tmpElem,
                                     "\n\n", "\n"), "\r\n\r\n", "\r\n")
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
                                if mdata["origin_company"] == nil then
                                    mdata["origin_company"] = {}
                                end
                                table.insert(mdata["origin_company"], tmpElem)
                            elseif xml_tv_nfo:name() == "director" then
                                -- "导演"标签
                                if mdata["person_staff"] == nil then
                                    mdata["person_staff"] = ''
                                end
                            mdata["person_staff"] = mdata["person_staff"] .. "Director:" .. tmpElem .. ';' -- Director-zh
                            elseif xml_tv_nfo:name() == "actor" then
                                -- "演员"标签组
                                if mdata["person_character"] == nil then
                                    -- 初始化table
                                    mdata["person_character"] = {}
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
                                        -- elseif xml_tv_nfo:name()=="content" then
                                        -- clink = tmpElem
                                        -- elseif xml_tv_nfo:name()=="content" then
                                        -- cimgurl = tmpElem
                                    end
                                    -- kiko.log('TEST  - Actor tag <'..xml_tv_nfo:name()..'>'..tmpElem)
                                end
                                xml_tv_nfo:readnext()
                            end
                            table.insert(mdata["person_character"], {
                                ["name"] = cname, -- 人物名称
                                ["actor"] = cactor -- 演员名称
                                -- ["link"]=clink,   --人物资料页URL
                                -- ["imgurl"]=cimgurl  --人物图片URL
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
                        mdata["backdrop_path"] = path_folder_lf .. "fanart.jpg"
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
        -- kiko.log(tableToStringLines(mediainfo))
        -- kiko.log("[INFO]  <epinfo>")
        -- kiko.log(tableToStringLines(epinfo))
        -- kiko.log("TEST  - others")
        -- kiko.log("| mname, mdata, murl, mairdate, myear | ename, eindex, etype, | mdata["season_number"], tstitle |")
        -- kiko.log("| mname, mdata, myear | ename, eindex, etype, | eseason, tstitle |")
        -- kiko.log('|', mname, '*', mdata, '*', murl, '*', mairdate, '*', myear)
        -- kiko.log('|', mname, '*', tableToString(mdata), '*', myear)
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
        ["title"] = "打开TMDb页面",
        ["id"] = "open_tmdb_webpage",
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

    if menuid == "open_tmdb_webpage" then
        -- 打开对应TMDb网页链接
        kiko.log("Open TMDb page of <"..anime["name"]..">.")
        kiko.message("打开 <"..anime["name"].."> 的TMDb页面", NM_HIDE)
        kiko.execute(true, "cmd", {"/c", "start", anime["url"]})
    elseif menuid == "show_media_matadata" then
        -- 显示媒体元数据

        -- local tipString="" -- 显示的媒体元数据文本
        -- 把媒体信息"data"的json的字符串转为<table>
        local err, anime_data = kiko.json2table(anime["data"])
        if err ~= nil then
            kiko.log(string.format("[ERROR] json2table: %s", err))
        end
        local dataString = ""
        if anime_data == nil then
            -- 无媒体信息
            kiko.log("[WARN]  (AnimeLite)anime[\"data\"] not found.")
        else
            -- 有anime["data"]字段
            dataString = tableToStringLines(anime_data or "", 1) .. dataString
        end
        if anime_data["media_type"] == nil then
            -- 无媒体类型信息
            kiko.log("[WARN]  (AnimeLite)anime[\"data\"][\"media_type\"] not found.")
        end
        -- tableToStringPrint(anime_data) -- kiko.log("")
        local tmpString, tipString = "", ""
        -- 格式化输出字符串
        tmpString = anime["name"]
        tipString = tipString .. "" .. "媒体标题：\t" .. (tmpString or "")
        tipString = tipString .. "\n" .. "原标题：\t\t" .. (anime_data["original_title"] or "")
        tmpString = anime["airdate"]
        tipString = tipString .. "\n" .. "首映/首播：\t" .. (tmpString or anime_data["release_date"] or "")
        tmpString = anime["epcount"]
        tipString = tipString .. "\n" .. "分集总数：\t" .. (tmpString or anime_data["episode_count"] or "")
        tipString = tipString .. "\n" .. "语言：\t\t" .. (anime_data["original_language"] or "")
        tipString = tipString .. "\n" .. "类型：\t\t" .. (arrayToString(anime_data["genre_names"]) or "")
        tipString = tipString .. "\n" .. "评分：\t\t" .. (anime_data["vote_average"] or "")
        tipString = tipString .. "\n\n" .. "演员表：\t" .. (tableToString(anime["crt"] or {}))
        tipString = tipString .. "\n" .. "职员表：\t" .. ((type(anime["staff"] or "") ~= "table") and
                            {anime["staff"]} or {tableToString(anime["staff"])})[1]
        tmpString = anime["url"]
        tipString = tipString .. "\n" .. "TMDb链接：\t" .. (tmpString or "")
        tmpString = anime["coverurl"]
        tipString = tipString .. "\n" .. "封面链接：\t" .. Image_tmdb.prefix..Image_tmdb.poster[Image_tmdb.max_ix] ..  (tmpString or anime_data["poster_path"] or "")
        tipString = tipString .. "\n" .. "背景链接：\t" .. Image_tmdb.prefix..Image_tmdb.backdrop[Image_tmdb.max_ix] ..  (tmpString or anime_data["backdrop_path"] or "")
        tmpString = anime["desc"]
        tipString = tipString .. "\n\n" .. "剧情介绍：\t" .. (tmpString or anime_data["overview"] or "")
        tipString = tipString .. "\n\n" .. "其他：\t\n" .. dataString --

        -- tipString=string.gsub(tipString,"\t","    ")
        -- kiko.log(tipString)
        -- kiko.log(dataString)
        -- kiko.dialog 疑似不支持多行显示？
        -- resTF ∈ ["accept","reject"]
        
        -- 获取 背景图 的二进制数据
        local img_back_data
        local header = {["Accept"] = "image/jpeg"}
        local err, reply = kiko.httpget(Image_tmdb.prefix..Image_tmdb.poster[Image_tmdb.mid_ix] ..  anime_data["backdrop_path"], {} , header)
        if err ~= nil then
            kiko.log("[ERROR] TMDb.API.reply-showmnfo.httpget: " .. err)
            if tostring(err) == ("Host requires authentication") then
                kiko.execute(true, "cmd", {"/c", "start", "https://www.themoviedb.org/settings/api"})
            end
            error(err)
        end
        img_back_data=reply["content"]
        -- kiko.log(reply)
        --[[
        local rf=io.open(sourcePath,"rb")
        local len = rf:seek("end")
        rf:seek("set",0)= rf:read(len)
        img_back_data = rf:read(len)
        ]]--

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
function getMediaInfoRawByFilename(filename)
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
			table.extendRaw(resSext,{"",""})
		else
			-- 含中文数字的集
			resSext=string.split(kiko.regex(patternSEZh,"i"):gsub(resTS[2],"\\2\t\\5\t\\7"),"\t")
			-- resSext=string.split(kiko.regex(patternSEZh,"i"):gsub(resTS[2],"\\2\t\\4\t\\6"),"\t")
			if resSext[1] ~= resTS[2] then
				table.extendRaw(resSext,{"",""})
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
            for key, value in pairs(zhnumToNum) do
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
	table.extendRaw(res,resSext)
	
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

-- 特殊字符转换 "&amp;" -> "&"  "&quot;" -> "\""
-- copy from & thanks to "..\\library\\bangumi.lua"
-- 在此可能用于媒体的标题名中的特殊符号，但是不知道需不需要、用不用得上。
function unescape(str)
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

-- 读 xml 文本文件
-- path_xml:video.nfo|file_nfo -> kiko.xmlreader:xml_file_nfo
-- 拓展名 .nfo，内容为 .xml 格式
-- 文件来自 Emby 的本地服务器 在电影/剧集文件夹存储 从网站刮削出的信息。
function readxmlfile(path_xml)

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

-- string.find reverse
-- 反向查找字符串首次出现
-- string:str  string:substr  number|int:ix -> number|int:字串首位索引
function stringfindre(str, substr, ix)
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

-- 打印 <table> 至 kiko
-- copy from & thanks to: https://blog.csdn.net/HQC17/article/details/52608464
-- { k = v }
Key_tts = "" -- 暂存来自上一级的键Key
function tableToStringPrint(table, level)
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
    for k, v in pairs(table) do
        if type(v) == "table" then
            -- <table>变量，递归
            Key_tts = k
            str = str .. tableToStringPrint(v, level + 1)
        else
            -- 普通变量，直接打印
            local content = string.format("%s%s = %s", indent .. "  ", tostring(k), tostring(v))
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
function tableToString(table0)
    --
    if type(table0) ~= "table" then
        -- 排除非<table>类型
        return ""
    end
    local str = "" -- 要return的字符串
    for k, v in pairs(table0) do
        if type(v) ~= "table" then
            -- 普通变量，直接扩展字符串
            str = str .. "(" .. k .. ")" .. v .. ", "
        else
            -- <table>变量，递归
            str = str .. "(" .. k .. ")" .. "[ " .. tableToString(v) .. " ], "
        end
    end
    return str
end
-- array 转 string - 把表转为字符串  （单向的转换，用于打印输出）
-- <array>table0 -> <string>:"v, [(k)v, (k)v], "
function arrayToString(table0)
    if type(table0) ~= "table" then
        -- 排除非<table>类型
        return ""
    end
    local str = "" -- 要return的字符串
    for k, v in pairs(table0) do
        if type(v) ~= "table" then
            -- 普通变量，直接扩展字符串
            str = str .. v .. ", "
        else
            -- <table>变量，递归
            str = str .. "[ " .. tableToString(v) .. " ], "
        end
    end
    return str
end
-- table 转 多行的string - 把表转为多行（含\n）的字符串  （单向的转换，用于打印输出）
-- <table>table0 -> <string>:"[k]\t v,\n [ (k)v,\t (k)v ], \n"
function tableToStringLines(table0, tabs)
    if tabs == nil then
        -- 根级别 无缩进
        tabs = 0
    end
    -- 排除非<table>类型
    if type(table0) ~= "table" then return "" end
    local str = "{ \n" -- 要return的字符串
    tabs = tabs + 1
    for k, v in pairs(table0) do
        for i = 1, tabs, 1 do
            -- 按与根相差的级别缩进，每一个递归加一
            str = str .. "\t"
        end
        if type(v) ~= "table" then
            -- 普通变量，直接扩展字符串
            str = str .. "[ " .. k .. " ] : \t" .. v .. "\n"
        else
            -- <table>变量，递归
            str = str .. "[ " .. k .. " ] : \t" .. "{ \n" .. tableToStringLines(v, tabs) .. " }\n"
        end
    end
    return str .. "\n} "
end

-- 判断table是否为 nil 或 {}
-- copy from & thanks to - https://www.cnblogs.com/njucslzh/archive/2013/02/02/2886876.html
function table.isEmpty(ta)
    if ta == nil then
        return true
    end
    return _G.next( ta ) == nil
end
-- 将tb的所有值依次接续到ta尾部，忽略tb中的键
function table.extendRaw(ta,tb)
    if ta == nil or type(ta) ~= "table" or tb == nil or type(tb) ~= "table" then
        -- 排除非<table>的变量
        return
    end
    for _, value in pairs(tb) do
        table.insert(ta,value)
    end
    return
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
