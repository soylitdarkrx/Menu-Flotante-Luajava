gg.setVisible(false)
local imports = {
    "android.view.*",
    "android.widget.*",
    "android.graphics.*",
    "android.graphics.drawable.*",
    "android.view.MotionEvent",
    "android.view.WindowManager",
    "android.animation.ObjectAnimator",
    "android.animation.ValueAnimator",
    "android.view.animation.LinearInterpolator",
    "android.view.animation.AccelerateDecelerateInterpolator",
    "android.graphics.Paint",
    "android.graphics.Canvas",
    "android.graphics.Typeface",
    "android.text.TextUtils$TruncateAt",
    "android.text.Editable",
    "android.text.TextWatcher",
    "android.view.KeyEvent",
    "android.view.inputmethod.InputMethodManager",
    "android.app.ActivityManager",
    "android.view.Choreographer"
}

for _, lib in ipairs(imports) do import(lib) end

local Build = luajava.bindClass("android.os.Build")
local LayoutParams = luajava.bindClass("android.view.WindowManager$LayoutParams")
local BitmapFactory = luajava.bindClass("android.graphics.BitmapFactory")
local Bitmap = luajava.bindClass("android.graphics.Bitmap")
local Canvas = luajava.bindClass("android.graphics.Canvas")
local Paint = luajava.bindClass("android.graphics.Paint")
local PorterDuff = luajava.bindClass("android.graphics.PorterDuff")
local PorterDuffXfermode = luajava.bindClass("android.graphics.PorterDuffXfermode")
local Rect = luajava.bindClass("android.graphics.Rect")
local Typeface = luajava.bindClass("android.graphics.Typeface")
local ColorStateList = luajava.bindClass("android.content.res.ColorStateList")
local GradientDrawable = luajava.bindClass("android.graphics.drawable.GradientDrawable")
local StateListDrawable = luajava.bindClass("android.graphics.drawable.StateListDrawable")
local FrameLayoutParams = luajava.bindClass("android.widget.FrameLayout$LayoutParams")
local LayerDrawable = luajava.bindClass("android.graphics.drawable.LayerDrawable")
local LinearLayoutParams = luajava.bindClass("android.widget.LinearLayout$LayoutParams")
local TruncateAt = luajava.bindClass("android.text.TextUtils$TruncateAt")
local Html = luajava.bindClass("android.text.Html")
local KeyEvent = luajava.bindClass("android.view.KeyEvent")
local InputMethodManager = luajava.bindClass("android.view.inputmethod.InputMethodManager")
local AccelerateDecelerateInterpolator = luajava.bindClass("android.view.animation.AccelerateDecelerateInterpolator")

local context = activity
local window = context.getSystemService("window")
local CRASH_LOG_PATH = "/sdcard/Xxx_Luajava_crash_log.txt"

local function write_log(err)
    local status = pcall(function()
        local msg = tostring(err or "nil")
        local trace = ""
        pcall(function()
            if debug and debug.traceback then
                trace = tostring(debug.traceback(msg, 2))
            end
        end)

        local file = io.open(CRASH_LOG_PATH, "a+")
        if file then
            file:write("\n============================\n")
            file:write(os.date("%Y-%m-%d %H:%M:%S") .. "\n")
            file:write("MAIN CRASH: " .. msg .. "\n")
            if trace ~= "" then
                file:write("TRACEBACK:\n" .. trace .. "\n")
            end
            file:close()
        end
    end)

    if not status then
        pcall(function()
            local fallback = io.open("/sdcard/Xxx_Luajava_crash_fallback.txt", "a+")
            if fallback then
                fallback:write("\n" .. os.date("%Y-%m-%d %H:%M:%S") .. " | " .. tostring(err) .. "\n")
                fallback:close()
            end
        end)
    end
end

local IMAGE_URL = "https://iili.io/BMBmXzG.md.jpg"
local FONT_URL = "https://github.com/FortAwesome/Font-Awesome/raw/master/webfonts/fa-solid-900.ttf"

local MENU_WIDTH_PERCENT = 0.75 -- WIDTH VERTICAL
local MENU_HEIGHT_PERCENT = 0.55 -- HEIGHT VERTICAL
local MENU_LAND_WIDTH_PERCENT = 0.55 --WIDTH HORIZONNTAL
local MENU_LAND_HEIGHT_PERCENT = 0.75 --HEIGJ HORIZONTAL
local MENU_MIN_WIDTH_DP = 320 -- MAXIMUM WIDTH LIMIT
local MENU_MIN_HEIGHT_DP = 220 -- MAXIMUM LOW HEIGHT LIMIT
local MENU_MAX_HEIGHT_DP = 360 -- MAXIMUM HEIGHT LIMIT
local lastScreenW, lastScreenH = 0, 0
local FontAwesome = nil 
local is_minimized = false 
local menu_active = true
local switchStates = {}
local running_packages = {}
local is_searching = false
local last_search_query = ""
local originalValues = {}
local first_load_done = false
local cached_apps = nil
local assets_loaded = { image = false, font = false }
local assets_error = { image = false, font = false }
local is_retrying = false
local fps_view = nil
local fps_label = nil
local show_fps_enabled = false
local Point = nil
local Point_posX_val, Point_posY_val = 100, 200
local Point_sizePx = "60dp" 

pcall(function()
    local HotPoint = luajava.bindClass("android.ext.HotPoint")
    local FloatPanel = luajava.bindClass("android.ext.FloatPanel")
    Point = HotPoint.instance
    
    local f_posX = FloatPanel.getDeclaredField("j"); f_posX.setAccessible(true)
    local f_posY = FloatPanel.getDeclaredField("k"); f_posY.setAccessible(true)
    Point_posX_val = f_posX.getInt(Point)
    Point_posY_val = f_posY.getInt(Point)
    
    local getSizeMethod = HotPoint.getDeclaredMethod("getSizePx", nil)
    getSizeMethod.setAccessible(true)
    Point_sizePx = tostring(getSizeMethod.invoke(Point, nil)).."px"
end)

local FontIcon = {-- Use this script to get icons: https://t.me/LitDarkRx_Ofc/575
    menu = {
        ['power-off'] = 0xF011,
        ['power'] = 0xf0e7,
        ['fa-user']      = 0xF007, 
        ['BookMark'] = 0xF02E, 
        ['search']    = 0xF002, 
        ['loading']   = 0xF1CE,
        ['close']     = 0xF00D,
        ['circle-notch'] = 0xf1ce,
        ['store'] = 0xF54E,
        ['fa-cog'] = 0xF4FE,
    },
    switches = {
        ['sw_fps']        = 0xF21D,
        ['sw_unlimit_ject'] = 0xF135,
        ['sw_Free_Shop']  = 0xF07A,   
        ['sw_unlock_skin'] = 0xF553,
        ['sw_unlock_board'] = 0xF7CE,
        ['sw_crosshair']  = 0xF05B,   
        ['sw_protection'] = 0xE06C,
    },
    seekbars = {
        ['sb_Game_Speed'] = 0xF70C,
        ['sb_fov']        = 0xF05B, 
    }
}

local OFFSET = {
    SWITCH = {

        ["sw_unlimit_ject"] = {
            {
                lib = 'libil2cpp.so',
                offset = 0x10AF53C,
                type = gg.TYPE_DWORD,
                valueOn = "010000E31EFF2FE1",
                valueOff = "F0482DE9F4519FE5"--We add valueOff if the hex False"Original" crashes
            }
        },

        ["sw_Free_Shop"] = {
            {
                lib = 'libil2cpp.so',
                offset = 0x31B751C,
                type = gg.TYPE_DWORD,
                valueOn = "000000E31EFF2FE1"-- If the hex False"Original doesn't crash, we add valueOff.
            }, --1 Offset ID: sw_Free_Shop
            {
                lib = 'libil2cpp.so',
                offset = 0x31B7520,
                type = gg.TYPE_DWORD,
                valueOn = "1EFF2FE1100F6FE1",
                valueOff = "0A0040E2100F6FE1"
            }-- 2 Offset ID: sw_Free_Shop
        },

        ["sw_unlock_skin"] = {
            {
                lib = 'libil2cpp.so',
                offset = 0x145DB0C,
                type = gg.TYPE_DWORD,
                valueOn = "1EFF2FE10000A003",
                valueOff = "000050E30000A003"
            },
            {
                lib = 'libil2cpp.so',
                offset = 0x145DB08,
                type = gg.TYPE_DWORD,
                valueOn = "010000E31EFF2FE1",
                valueOff = "180090E5000050E3"
            }
        },

        ["sw_unlock_board"] = {
            {
                lib = 'libil2cpp.so',
                offset = 0x1432124,
                type = gg.TYPE_DWORD,
                valueOn = "010000E31EFF2FE1",
                valueOff = "70402DE990609FE5"
            },
            {
                lib = 'libil2cpp.so',
                offset = 0x1431C58,
                type = gg.TYPE_DWORD,
                valueOn = "010000E31EFF2FE1",
                valueOff = "180090E5000050E3"
            }
        }
    },

    SEKBAR = {
        ["sb_Game_Speed"] = {
            {
                lib = 'libil2cpp.so',
                offset = 0xF89CF8,
                type = gg.TYPE_FLOAT
            }
        }
    }
}

local function toJavaInt(hex)
    local status, result = pcall(function()
        local num = tonumber(hex, 16)
        if num > 2147483647 then num = num - 4294967296 end
        return math.floor(num)
    end)
    if not status then return 0 end
    return result
end

local function updateBallOpacity(view, fullAlpha)
    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            local anim = ObjectAnimator.ofFloat(view, "alpha", view.getAlpha(), fullAlpha and 1.0 or 0.4)
            anim.setDuration(500)
            anim.start()
        end
    }))
end

function dp2px(dp)
    return math.floor(dp * context.getResources().getDisplayMetrics().density + 0.5)
end

local function getScreenSize()
    local metrics = context.getResources().getDisplayMetrics()
    return metrics.widthPixels, metrics.heightPixels
end

local function applyResponsiveMenuSize(lpObj)
    if not lpObj then return end

    local screenWidth, screenHeight = getScreenSize()
    local isLandscape = screenWidth > screenHeight

    local wPercent = isLandscape and MENU_LAND_WIDTH_PERCENT or MENU_WIDTH_PERCENT
    local hPercent = isLandscape and MENU_LAND_HEIGHT_PERCENT or MENU_HEIGHT_PERCENT

    local finalW = math.floor(screenWidth * wPercent)
    local finalH = math.floor(screenHeight * hPercent)

    local minW = dp2px(MENU_MIN_WIDTH_DP)
    local minH = dp2px(MENU_MIN_HEIGHT_DP)
    local maxH = dp2px(MENU_MAX_HEIGHT_DP)

    if finalW < minW then finalW = minW end
    if finalH < minH then finalH = minH end
    if finalH > maxH then finalH = maxH end

    if finalW > screenWidth - dp2px(40) then
        finalW = screenWidth - dp2px(40)
    end

    if finalH > screenHeight - dp2px(40) then
        finalH = screenHeight - dp2px(40)
    end

    lpObj.width = finalW
    lpObj.height = finalH
end

local function neonFlowPro(container)
    local View = luajava.bindClass("android.view.View")
    local FrameLayout = luajava.bindClass("android.widget.FrameLayout")
    
    local pulse = ObjectAnimator.ofFloat(container, "alpha", 0.85, 1)
    pulse.setDuration(1200); pulse.setRepeatCount(ValueAnimator.INFINITE); pulse.setRepeatMode(ValueAnimator.REVERSE); pulse.start()
    
    local line1 = luajava.new(View, context); line1.setBackgroundColor(0x66FFFFFF)
    local lp1 = FrameLayoutParams(dp2px(80), dp2px(2)); lp1.topMargin = dp2px(8); container.addView(line1, lp1)
    local anim1 = ObjectAnimator.ofFloat(line1, "translationX", dp2px(350), -dp2px(80))
    anim1.setDuration(1800); anim1.setRepeatCount(ValueAnimator.INFINITE); anim1.setInterpolator(LinearInterpolator()); anim1.start()
    
    local line2 = luajava.new(View, context); line2.setBackgroundColor(0x33FFFFFF)
    local lp2 = FrameLayoutParams(dp2px(60), dp2px(1)); lp2.topMargin = dp2px(16); container.addView(line2, lp2)
    local anim2 = ObjectAnimator.ofFloat(line2, "translationX", dp2px(350), -dp2px(60))
    anim2.setDuration(2200); anim2.setRepeatCount(ValueAnimator.INFINITE); anim2.setInterpolator(LinearInterpolator()); anim2.start()
    
    for i = 1, 5 do
        local dot = luajava.new(View, context); dot.setBackgroundColor(0xFFFFFFFF)
        local size = dp2px(2)
        local params = FrameLayoutParams(size, size); params.topMargin = math.random(0, dp2px(23)); container.addView(dot, params)
        
        local move = ObjectAnimator.ofFloat(dot, "translationX", dp2px(350), -dp2px(10))
        move.setDuration(math.random(2000, 3500)); move.setRepeatCount(ValueAnimator.INFINITE); move.setInterpolator(LinearInterpolator())
        
        local fade = ObjectAnimator.ofFloat(dot, "alpha", 0.2, 1)
        fade.setDuration(math.random(800, 1500)); fade.setRepeatCount(ValueAnimator.INFINITE); fade.setRepeatMode(ValueAnimator.REVERSE)
        
        move.start(); fade.start()
    end
    
    local glow = ObjectAnimator.ofFloat(container, "scaleX", 1, 1.01)
    glow.setDuration(1500); glow.setRepeatCount(ValueAnimator.INFINITE); glow.setRepeatMode(ValueAnimator.REVERSE); glow.start()
end

local function getIcon(code) return utf8.char(code) end

local function applyIcons()
    pcall(function()
        if not FontAwesome then return end
        
        local function setIcon(view, code, text)
            if view and code then
                view.setTypeface(FontAwesome)
                local icon = utf8.char(code)
                if text then
                    view.setText(icon .. "  " .. text)
                else
                    view.setText(icon)
                end
            end
        end
        
        setIcon(btn_settings_nut, FontIcon.menu['fa-cog'])
        setIcon(btn_exit, FontIcon.menu['close'], "CLOSE")        
        setIcon(tab_player, FontIcon.menu['fa-user'], "PLAYER")
        setIcon(tab_power, FontIcon.menu['power'], "POWER")
        setIcon(tab_store, FontIcon.menu['store'], "STORE")
        
        if menu_title then
            menu_title.setTypeface(FontAwesome)
            local titleIcon = utf8.char(FontIcon.menu['BookMark'])
            local currentText = tostring(menu_title.getText()):gsub(utf8.char(FontIcon.menu['BookMark']), ""):gsub("^%s+", "")
            menu_title.setText(titleIcon .. "  " .. currentText)
        end
    end)
end

local function getCircularBitmap(bitmap)
    local status, result = pcall(function()
        if not bitmap then return nil end
        local width, height = bitmap.getWidth(), bitmap.getHeight()
        local size = math.min(width, height)
        local output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        local canvas = luajava.new(Canvas, output)
        local paint = luajava.new(Paint)
        local rect = luajava.new(Rect, (width - size) / 2, (height - size) / 2, (width + size) / 2, (height + size) / 2)
        local rectDestination = luajava.new(Rect, 0, 0, size, size)        
        paint.setAntiAlias(true)
        canvas.drawCircle(size / 2, size / 2, size / 2, paint)      
        paint.setXfermode(luajava.new(PorterDuffXfermode, PorterDuff.Mode.SRC_IN))
        canvas.drawBitmap(bitmap, rect, rectDestination, paint)       
        return output
    end)
    return status and result or bitmap
end

local function startPulseAnimation(view)
    if not view then return end
    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            pcall(function()
                local parent = view.getParent()
                if parent then
                    parent.setClipChildren(false)
                    parent.setClipToPadding(false)
                end
            end)
            local scaleX = ObjectAnimator.ofFloat(view, "scaleX", 1.0, 1.08)
            local scaleY = ObjectAnimator.ofFloat(view, "scaleY", 1.0, 1.08)
            scaleX.setDuration(1200); scaleX.setRepeatCount(-1); scaleX.setRepeatMode(2)
            scaleY.setDuration(1200); scaleY.setRepeatCount(-1); scaleY.setRepeatMode(2)
            scaleX.start(); scaleY.start()
        end
    }))
end

local function load_assets_direct()
    assets_error.image = false
    assets_error.font = false
    thread(function()
        local URL = luajava.bindClass("java.net.URL")
        local Array = luajava.bindClass("java.lang.reflect.Array")
        local Byte = luajava.bindClass("java.lang.Byte")
        
        local function processDownload(urlStr, type, id)
            local success = false
            pcall(function()
                local conn = URL(urlStr).openConnection()
                conn.setConnectTimeout(10000)
                conn.setRequestProperty("User-Agent", "Mozilla/5.0")
                
                if conn.getResponseCode() == 200 then
                    local input = conn.getInputStream()
                    if type == "font" then
                        local tempPath = context.getFilesDir().getAbsolutePath() .. "/fa-solid-900.ttf"
                        local output = luajava.new(luajava.bindClass("java.io.FileOutputStream"), tempPath)
                        local buffer = Array.newInstance(Byte.TYPE, 8192)
                        local bytesRead = input.read(buffer)
                        while bytesRead ~= -1 do output.write(buffer, 0, bytesRead) bytesRead = input.read(buffer) end
                        output.close() input.close()
                        FontAwesome = luajava.bindClass("android.graphics.Typeface").createFromFile(tempPath)
                        activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { 
                            run = function() assets_loaded.font = true; applyIcons(); updateTabContent("PLAYER") end 
                        }))
                    elseif type == "image" then
                        local bitmap = BitmapFactory.decodeStream(input)
                        if bitmap then
                            local circular = getCircularBitmap(bitmap)
                            _G["cached_banner"] = circular
                            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { 
                                run = function() 
                                    if img_banner then 
                                        img_banner.setImageBitmap(circular)
                                        img_banner.setBackground(nil)
                                        startPulseAnimation(img_banner) 
                                    end
                                    assets_loaded.image = true 
                                end 
                            }))
                        end
                    end
                    success = true
                end
            end)
            return success
        end

        processDownload(IMAGE_URL, "image", "main_banner")
        processDownload(FONT_URL, "font")
    end)
end

local function loadLogo(ImageView)
    thread(function()
        local status, bitmap = pcall(function() 
            local conn = luajava.bindClass("java.net.URL")(IMAGE_URL).openConnection()
            conn.setConnectTimeout(10000)
            conn.setRequestProperty("User-Agent", "Mozilla/5.0")
            return BitmapFactory.decodeStream(conn.getInputStream())
        end)
        
        activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
            run = function()
                if status and bitmap then
                    local circular = getCircularBitmap(bitmap)
                    if ImageView then
                        ImageView.setImageBitmap(circular)
                        ImageView.setBackground(nil)
                        startPulseAnimation(ImageView)
                    end
                    if img_banner and img_banner ~= ImageView then
                        img_banner.setImageBitmap(circular)
                        img_banner.setBackground(nil)
                        startPulseAnimation(img_banner)
                    end
                    assets_loaded.image = true
                else
                    assets_error.image = true
                end
            end
        }))
    end)
end


local function createFpsOverlay()
    if fps_view then return end
    
    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            pcall(function()
                fps_view = luajava.new(LinearLayout, context)
                fps_view.setOrientation(0)
                fps_view.setGravity(17)
                fps_view.setPadding(dp2px(12), dp2px(4), dp2px(12), dp2px(4))
                
                local gd = luajava.new(GradientDrawable)
                gd.setColor(toJavaInt("D91C1C1E")) 
                gd.setCornerRadius(dp2px(20)) 
                gd.setStroke(dp2px(0.5), toJavaInt("4DFFFFFF")) 
                fps_view.setBackground(gd)
                
                fps_label = luajava.new(TextView, context)
                fps_label.setTextColor(toJavaInt("FF34C759")) 
                fps_label.setTextSize(13) 
                fps_label.setTypeface(Typeface.create("sans-serif-medium", Typeface.NORMAL))
                fps_label.setText("FPS: --")
                fps_view.addView(fps_label)
                
                local f_lp = luajava.new(LayoutParams)
                f_lp.type = (Build.VERSION.SDK_INT >= 26) and 2038 or 2002
                f_lp.format = -3
                f_lp.gravity = 51 
                f_lp.flags = 8 | 16 | 32 
                f_lp.width = -2
                f_lp.height = -2
                f_lp.x = dp2px(25) 
                f_lp.y = dp2px(25) 
                
                window.addView(fps_view, f_lp)
                fps_view.setVisibility(8)
            end)
        end
    }))
end

local function toggleFpsCounter(enable)
    show_fps_enabled = enable
    if not fps_view then createFpsOverlay() end
    
    local System = luajava.bindClass("java.lang.System")
    local Choreographer = luajava.bindClass("android.view.Choreographer")
    
    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            if fps_view then 
                pcall(function()
                    if enable then
                        fps_view.setVisibility(0)
                        fps_view.setAlpha(0)
                        fps_view.setScaleX(0.8)
                        fps_view.setScaleY(0.8)
                        fps_view.animate()
                            .alpha(1)
                            .scaleX(1)
                            .scaleY(1)
                            .setDuration(400)
                            .setInterpolator(luajava.new(AccelerateDecelerateInterpolator))
                            .start()
                    else
                        fps_view.animate()
                            .alpha(0)
                            .scaleX(0.8)
                            .scaleY(0.8)
                            .setDuration(300)
                            .withEndAction(luajava.createProxy("java.lang.Runnable", {
                                run = function() fps_view.setVisibility(8) end
                            })).start()
                    end
                end)
            end
        end
    }))

    if enable then
        thread(function()
            local lastMillis = System.currentTimeMillis()
            local frames = 0
            local frameCallback
            
            frameCallback = luajava.createProxy("android.view.Choreographer$FrameCallback", {
                doFrame = function(frameTimeNanos)
                    if show_fps_enabled and (menu_active ~= false) then
                        frames = frames + 1
                        Choreographer.getInstance().postFrameCallback(frameCallback)
                    end
                end
            })

            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
                run = function() Choreographer.getInstance().postFrameCallback(frameCallback) end
            }))

            while show_fps_enabled and (menu_active ~= false) do 
                local currentMillis = System.currentTimeMillis()
                local diff = currentMillis - lastMillis
                
                if diff >= 500 then 
                    local fps = math.floor((frames * 1000) / diff)
                    if fps > 121 then fps = 60 end 

                    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
                        run = function()
                            pcall(function()
                                if fps_label and fps_view and fps_view.getParent() ~= nil then 
                                    fps_label.setText(string.format("FPS: %d", fps))
                                    
                                    if fps >= 55 then
                                        fps_label.setTextColor(toJavaInt("FF34C759")) 
                                    elseif fps >= 35 then
                                        fps_label.setTextColor(toJavaInt("FFFF9F0A")) 
                                    else
                                        fps_label.setTextColor(toJavaInt("FFFF3B30")) 
                                    end
                                end
                            end)
                        end
                    }))
                    frames = 0
                    lastMillis = currentMillis
                end
                gg.sleep(100) 
            end
        end)
    end
end

local function neonMarqueeFlow(targetView)
    pcall(function()
        targetView.post(luajava.createProxy("java.lang.Runnable", {
            run = function()
                local parent = targetView.getParent()
                if not parent then return end
                local parentWidth = parent.getWidth()
                targetView.measure(0, 0)
                local textWidth = targetView.getMeasuredWidth()
                local anim = ObjectAnimator.ofFloat(targetView, "translationX", parentWidth, -textWidth)
                anim.setDuration(8000) 
                anim.setRepeatCount(ValueAnimator.INFINITE)
                anim.setInterpolator(LinearInterpolator())
                anim.start()
            end
        }))
    end)
end

local function addAnimatedBorder(rootView)
    pcall(function()
        local View = luajava.bindClass("android.view.View")
        local SystemClock = luajava.bindClass("android.os.SystemClock")
        local FrameLayout = luajava.bindClass("android.widget.FrameLayout")
        
        local density = context.getResources().getDisplayMetrics().density
        local function dp(val) return math.floor(val * density + 0.5) end
        
        local borderThickness = dp(3.5)
        local lineLength = dp(140)
        local pixelsPerSecond = dp(350)
        local menuRadius = dp(12)
        
        local contentFrame = rootView.findViewWithTag("main_frame")
        if contentFrame then
            local backBg = luajava.new(GradientDrawable)
            backBg.setColor(toJavaInt("CD000000"))
            backBg.setCornerRadius(menuRadius)
            local strokeBg = luajava.new(GradientDrawable)
            strokeBg.setCornerRadius(menuRadius)
            strokeBg.setStroke(dp(1), toJavaInt("30FFFFFF"))
            contentFrame.setBackground(luajava.new(LayerDrawable, {backBg, strokeBg}))
        end

        local borderContainer = rootView.findViewWithTag("border_layer")
        if not borderContainer then
            borderContainer = luajava.new(FrameLayout, context)
            borderContainer.setTag("border_layer")
            rootView.addView(borderContainer)
        end
        borderContainer.bringToFront()

        local function createLineView()
            local f = luajava.new(FrameLayout, context)
            local v = luajava.new(View, context)
            local shape = luajava.new(GradientDrawable)
            shape.setShape(GradientDrawable.RECTANGLE)
            shape.setCornerRadius(menuRadius)
            shape.setStroke(borderThickness, toJavaInt("FFFF0000"))
            shape.setColor(0)
            v.setBackground(shape)
            f.addView(v)
            f.setVisibility(View.INVISIBLE)
            return f, v
        end

        borderContainer.removeAllViews()
        local topF, topV = createLineView()
        local rightF, rightV = createLineView()
        local bottomF, bottomV = createLineView()
        local leftF, leftV = createLineView()
        
        borderContainer.addView(topF); borderContainer.addView(rightF)
        borderContainer.addView(bottomF); borderContainer.addView(leftF)

        local currentEdge, pos = 1, 0
        local lastTime = SystemClock.uptimeMillis()
        
        local function getFluentColor(t)
            local r = math.floor(math.sin(t * 0.002 + 0) * 127 + 128)
            local g = math.floor(math.sin(t * 0.002 + 2) * 127 + 128)
            local b = math.floor(math.sin(t * 0.002 + 4) * 127 + 128)
            local raw = (255 * 16777216) + (r * 65536) + (g * 256) + b
            return math.floor(raw > 2147483647 and raw - 4294967296 or raw)
        end

        local function animate()
            pcall(function()
                if borderContainer.getVisibility() ~= View.VISIBLE then 
                    rootView.postDelayed(luajava.createProxy("java.lang.Runnable", {run=animate}), 100)
                    return 
                end

                local currentTime = SystemClock.uptimeMillis()
                local deltaTime = (currentTime - lastTime) / 1000
                lastTime = currentTime

                local w, h = borderContainer.getWidth(), borderContainer.getHeight()
                if w > 0 and h > 0 then
                    pos = pos + (pixelsPerSecond * deltaTime)
                    local activeColor = getFluentColor(currentTime)

                    local frames = {topF, rightF, bottomF, leftF}
                    local views = {topV, rightV, bottomV, leftV}

                    for i=1, 4 do 
                        frames[i].setVisibility(i == currentEdge and View.VISIBLE or View.INVISIBLE) 
                    end

                    local f, v = frames[currentEdge], views[currentEdge]
                    v.getBackground().setStroke(borderThickness, activeColor)

                    local lp = v.getLayoutParams()
                    if lp.width ~= w or lp.height ~= h then
                        lp.width, lp.height = w, h
                        v.setLayoutParams(lp)
                    end

                    if currentEdge == 1 then
                        f.setTranslationX(pos - lineLength); f.setTranslationY(0)
                        v.setTranslationX(-(pos - lineLength)); v.setTranslationY(0)
                        f.getLayoutParams().width, f.getLayoutParams().height = lineLength, borderThickness * 2
                    elseif currentEdge == 2 then
                        f.setTranslationX(w - borderThickness * 2); f.setTranslationY(pos - lineLength)
                        v.setTranslationY(-(pos - lineLength)); v.setTranslationX(-(w - borderThickness * 2))
                        f.getLayoutParams().width, f.getLayoutParams().height = borderThickness * 2, lineLength
                    elseif currentEdge == 3 then
                        f.setTranslationX(w - pos); f.setTranslationY(h - borderThickness * 2)
                        v.setTranslationX(-(w - pos)); v.setTranslationY(-(h - borderThickness * 2))
                        f.getLayoutParams().width, f.getLayoutParams().height = lineLength, borderThickness * 2
                    elseif currentEdge == 4 then
                        f.setTranslationX(0); f.setTranslationY(h - pos)
                        v.setTranslationY(-(h - pos)); v.setTranslationX(0)
                        f.getLayoutParams().width, f.getLayoutParams().height = borderThickness * 2, lineLength
                    end
                    
                    f.requestLayout()

                    if pos >= ((currentEdge % 2 == 1 and w or h) + lineLength) then
                        pos = 0
                        currentEdge = currentEdge < 4 and currentEdge + 1 or 1
                    end
                end
                rootView.postDelayed(luajava.createProxy("java.lang.Runnable", {run=animate}), 16)
            end)
        end
        rootView.post(luajava.createProxy("java.lang.Runnable", {run=animate}))
    end)
end

local function startRotationFix()
    thread(function()
        while menu_active do
            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
                run = function()
                    pcall(function()
                        if not lp or not view then return end

                        local sw, sh = getScreenSize()

                        if sw ~= lastScreenW or sh ~= lastScreenH then
                            lastScreenW = sw
                            lastScreenH = sh

                            local oldX = lp.x or 0
                            local oldY = lp.y or 0

                            applyResponsiveMenuSize(lp)

                            lp.x = oldX
                            lp.y = oldY

                            local maxX = math.floor((sw - lp.width) / 2)
                            local maxY = math.floor((sh - lp.height) / 2)

                            if lp.x > maxX then lp.x = maxX end
                            if lp.x < -maxX then lp.x = -maxX end
                            if lp.y > maxY then lp.y = maxY end
                            if lp.y < -maxY then lp.y = -maxY end

                            window.updateViewLayout(view, lp)

                            if root then
                                root.requestLayout()
                                root.invalidate()
                            end
                        end
                    end)
                end
            }))
            gg.sleep(300)
        end
    end)
end

local function setBorderVisible(visible)
    pcall(function()
        if root then
            local border = root.findViewWithTag("border_layer")
            if border then
                border.setVisibility(visible and 0 or 8)
            end
        end
    end)
end

local function setMenuMinimized(minimize)
    is_minimized = minimize

    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            pcall(function()
                if not lp or not view then return end

                if minimize then
                    if root then
                        root.setVisibility(0)
                        root.setBackgroundColor(0x00000000)
                        root.setPadding(0, 0, 0, 0)
                        root.setClipChildren(false)
                        root.setClipToPadding(false)
                    end

                    if mFrame then
                        mFrame.setVisibility(0)
                        mFrame.setBackground(nil)
                        mFrame.setPadding(0, 0, 0, 0)
                        mFrame.setClipChildren(false)
                        mFrame.setClipToPadding(false)
                    end

                    if main_content then
                        main_content.setVisibility(0)
                        main_content.setPadding(0, 0, 0, 0)
                        main_content.setClipChildren(false)
                        main_content.setClipToPadding(false)
                    end

                    if side_container then
                        side_container.setVisibility(0)
                        side_container.setGravity(17)
                        side_container.setClipChildren(false)
                        side_container.setClipToPadding(false)

                        local sideLp = side_container.getLayoutParams()
                        sideLp.width = dp2px(70)
                        sideLp.height = dp2px(70)
                        side_container.setLayoutParams(sideLp)
                    end

                    if sidebar_content then
                        sidebar_content.setVisibility(8)
                    end

                    if separator_container then
                        separator_container.setVisibility(8)
                    end

                    if container_right then
                        container_right.setVisibility(8)
                    end

                    if global_splash then
                        global_splash.setVisibility(8)
                    end

                    setBorderVisible(false)

                    if img_banner then
                        img_banner.setVisibility(0)
                        img_banner.setClickable(true)
                        img_banner.setAlpha(1)
                        img_banner.setScaleX(1)
                        img_banner.setScaleY(1)
                        img_banner.setBackground(nil)

                        local imgLp = luajava.new(LinearLayoutParams, dp2px(60), dp2px(60))
                        imgLp.gravity = 1
                        img_banner.setLayoutParams(imgLp)
                    end

                    lp.width = dp2px(70)
                    lp.height = dp2px(70)
                    lp.flags = 8 | 32

                else
                    if root then
                        root.setVisibility(0)
                        root.setBackgroundColor(0x00000000)
                        root.setClipChildren(false)
                        root.setClipToPadding(false)
                    end

                    if mFrame then
                        mFrame.setVisibility(0)
                        mFrame.setPadding(0, 0, 0, 0)
                        mFrame.setClipChildren(false)
                        mFrame.setClipToPadding(false)

                        local backBg = luajava.new(GradientDrawable)
                        backBg.setColor(toJavaInt("CD000000"))
                        backBg.setCornerRadius(dp2px(12))

                        local strokeBg = luajava.new(GradientDrawable)
                        strokeBg.setCornerRadius(dp2px(12))
                        strokeBg.setStroke(dp2px(1), toJavaInt("30FFFFFF"))

                        mFrame.setBackground(
                            luajava.new(LayerDrawable, {
                                backBg,
                                strokeBg
                            })
                        )
                    end

                    if main_content then
                        main_content.setVisibility(0)
                        main_content.setPadding(
                            dp2px(10),
                            dp2px(10),
                            dp2px(10),
                            dp2px(10)
                        )
                        main_content.setClipChildren(false)
                        main_content.setClipToPadding(false)
                    end

                    if side_container then
                        side_container.setVisibility(0)
                        side_container.setGravity(1)

                        local sideLp = side_container.getLayoutParams()
                        sideLp.width = -2
                        sideLp.height = -1
                        side_container.setLayoutParams(sideLp)
                    end

                    if sidebar_content then
                        sidebar_content.setVisibility(0)
                    end

                    if separator_container then
                        separator_container.setVisibility(0)
                    end

                    if container_right then
                        container_right.setVisibility(0)
                    end

                    setBorderVisible(true)

                    if img_banner then
                        img_banner.setVisibility(0)
                        img_banner.setClickable(true)
                        img_banner.setAlpha(1)
                        img_banner.setScaleX(1)
                        img_banner.setScaleY(1)

                        local imgLp = luajava.new(LinearLayoutParams, dp2px(55), dp2px(55))
                        imgLp.gravity = 1
                        img_banner.setLayoutParams(imgLp)
                    end

                    applyResponsiveMenuSize(lp)

                    lp.flags = 8 | 32
                end

                window.updateViewLayout(view, lp)

                if root then
                    root.requestLayout()
                    root.invalidate()
                end
            end)
        end
    }))
end

local function getGradientShape(colors, radius, strokeColor, strokeWidth)
    local d = luajava.new(GradientDrawable, GradientDrawable.Orientation.TOP_BOTTOM, colors)
    d.setCornerRadius(radius); if strokeColor then d.setStroke(strokeWidth or dp2px(1.8), strokeColor) end; return d
end

local function getAnimatedDrawable(normalColors, radius, strokeColor)
    local states = luajava.new(StateListDrawable)
    states.addState({android.R.attr.state_pressed}, getGradientShape({0xFF5555FF, 0xFFAAAAFF}, radius, 0xFFFFFFFF, dp2px(2.5)))
    states.addState({}, getGradientShape(normalColors, radius, strokeColor)); return states
end

local function syncFlagSecure(lp, window, view)
    if not lp or not window or not view then return end
    local FLAG_SECURE = 8192
    if switchStates["sw_protection"] then
        lp.flags = (lp.flags | FLAG_SECURE)
    else
        lp.flags = (lp.flags & ~FLAG_SECURE)
    end
    pcall(function() window.updateViewLayout(view, lp) end)
end

local function showToast(message, isEnabled)
    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            local ok, err = pcall(function()
                local DecelerateInterpolator = luajava.bindClass("android.view.animation.DecelerateInterpolator")
                local AccelerateInterpolator = luajava.bindClass("android.view.animation.AccelerateInterpolator")

                if not context then return end

                local toastFrame = luajava.new(LinearLayout, context)
                toastFrame.setOrientation(0)
                toastFrame.setGravity(17)
                toastFrame.setPadding(dp2px(20), dp2px(12), dp2px(20), dp2px(12))

                local gd = luajava.new(GradientDrawable)
                gd.setColor(toJavaInt("F2101010"))
                gd.setCornerRadius(dp2px(28))
                gd.setStroke(dp2px(1), toJavaInt("30FFFFFF"))
                toastFrame.setBackground(gd)

                local iconView = luajava.new(TextView, context)
                iconView.setTextSize(18)
                iconView.setPadding(0, 0, dp2px(10), 0)

                if FontAwesome then
                    iconView.setTypeface(FontAwesome)
                    iconView.setText(getIcon(isEnabled and 0xf058 or 0xf057))
                    iconView.setTextColor(toJavaInt(isEnabled and "FF34C759" or "FFFF3B30"))
                else
                    iconView.setText(isEnabled and "✓ " or "✗ ")
                    iconView.setTextColor(toJavaInt(isEnabled and "FF34C759" or "FFFF3B30"))
                end

                local toastText = luajava.new(TextView, context)
                toastText.setText(message)
                toastText.setTextColor(0xFFFFFFFF)
                toastText.setTextSize(14)

                toastFrame.addView(iconView)
                toastFrame.addView(toastText)

                local wm = context.getSystemService(context.WINDOW_SERVICE)
                local p = luajava.new(WindowManager.LayoutParams)
                p.height = -2
                p.width = -2
                p.format = -3
                p.type = 2038
                p.flags = 8 | 32 | 262144
                p.gravity = 49
                p.y = dp2px(60)

                wm.addView(toastFrame, p)

                toastFrame.setAlpha(0)
                toastFrame.setTranslationY(-dp2px(80))
                toastFrame.setScaleX(0.85)
                toastFrame.setScaleY(0.85)

                toastFrame.animate()
                    .alpha(1)
                    .translationY(0)
                    .scaleX(1.0)
                    .scaleY(1.0)
                    .setDuration(320)
                    .setInterpolator(luajava.new(DecelerateInterpolator, 1.1))
                    .start()

                thread(function()
                    gg.sleep(2200)
                    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
                        run = function()
                            toastFrame.animate()
                                .alpha(0)
                                .translationY(-dp2px(50))
                                .scaleX(0.9)
                                .scaleY(0.9)
                                .setDuration(250)
                                .setInterpolator(luajava.new(AccelerateInterpolator))
                                .withEndAction(luajava.createProxy("java.lang.Runnable", {
                                    run = function()
                                        pcall(function() wm.removeView(toastFrame) end)
                                    end
                                }))
                                .start()
                        end
                    }))
                end)
            end)
        end
    }))
end

local function cleanHex(hex)
    hex = tostring(hex or "")
    hex = hex:gsub("^h", "")
    hex = hex:gsub("%s+", "")
    return hex
end

local function hexToBytes(hex)
    hex = cleanHex(hex)
    local t = {}
    for i = 1, #hex, 2 do
        local b = tonumber(hex:sub(i, i + 1), 16)
        if b then
            if b > 127 then b = b - 256 end
            table.insert(t, b)
        end
    end
    return t
end

local function readBytes(address, count)
    local list = {}
    for i = 0, count - 1 do
        table.insert(list, {
            address = address + i,
            flags = gg.TYPE_BYTE
        })
    end

    local data = gg.getValues(list)
    local out = {}

    for i, v in ipairs(data) do
        out[i] = v.value
    end

    return out
end

local function writeBytes(address, bytes)
    local list = {}
    for i, b in ipairs(bytes) do
        table.insert(list, {
            address = address + i - 1,
            flags = gg.TYPE_BYTE,
            value = b
        })
    end
    gg.setValues(list)
end

local function editranges(searchValue, resultLimit, replaceValue, ranges, vtype)
    local ok, result = pcall(function()
        gg.clearResults()
        gg.setRanges(ranges)

        local limit = tonumber(resultLimit) or 4000
        gg.searchNumber(searchValue, vtype, false, gg.SIGN_EQUAL, 0, -1)

        local results = gg.getResults(limit)
        if not results or #results == 0 then
            gg.clearResults()
            return false
        end

        gg.editAll(replaceValue, vtype)
        gg.clearResults()
        return true
    end)

    if not ok then
        gg.clearResults()
        return false
    end

    return result == true
end

local function editMemory(lib, offset, vtype, newValue, label, isChecked)
    local status, result = pcall(function()
        local so_list = gg.getRangesList(lib)

        if not so_list or #so_list == 0 then
            showToast("ERROR: " .. lib .. " no encontrada", false)
            return false
        end

        local address = so_list[1].start + offset
        local key = lib .. "_" .. string.format("0x%X", offset)

        local isHexPatch = type(newValue) == "string" and cleanHex(newValue):match("^[A-Fa-f0-9]+$") and (#cleanHex(newValue) % 2 == 0)

        if isHexPatch then
            local patchBytes = hexToBytes(newValue)

            if originalValues[key] == nil then
                originalValues[key] = readBytes(address, #patchBytes)
            end

            writeBytes(address, patchBytes)
        else
            if originalValues[key] == nil then
                local data = gg.getValues({
                    {
                        address = address,
                        flags = vtype
                    }
                })

                if data and data[1] then
                    originalValues[key] = data[1].value
                end
            end

            gg.setValues({
                {
                    address = address,
                    flags = vtype,
                    value = newValue
                }
            })
        end

        gg.clearResults()
        showToast(label .. (isChecked and " ACTIVADO" or " DESACTIVADO"), isChecked)
        return true
    end)

    if not status then
        showToast("FALLO EN OFFSET", false)
        return false
    end

    return result == true
end

local function addStyledSwitch(parent, label, key)
    local container = luajava.new(LinearLayout, context)
    container.setOrientation(0)
    container.setGravity(16)
    container.setPadding(dp2px(12), dp2px(10), dp2px(12), dp2px(10))

    container.setBackground(
        getGradientShape(
            {
                toJavaInt("FF0A0A0A"),
                toJavaInt("FF111111")
            },
            dp2px(10),
            toJavaInt("FF222222"),
            dp2px(1)
        )
    )

    local textContainer = luajava.new(LinearLayout, context)
    textContainer.setLayoutParams(
        luajava.new(LinearLayoutParams, 0, -2, 1)
    )
    textContainer.setGravity(16)

    local iconView = luajava.new(TextView, context)
    iconView.setTextColor(toJavaInt("FF007AFF"))
    iconView.setTextSize(16)
    iconView.setPadding(0, 0, dp2px(10), 0)

    if FontAwesome then
        iconView.setTypeface(FontAwesome)

        local iconCode =
            FontIcon.switches[key]
            or FontIcon.menu['power-off']

        iconView.setText(utf8.char(iconCode))
    end

    local txt = luajava.new(TextView, context)
    txt.setTextColor(-1)
    txt.setTextSize(10.5)
    txt.setText(label)

    textContainer.addView(iconView)
    textContainer.addView(txt)

    local sw = luajava.new(Switch, context)
    sw.setChecked(switchStates[key] or false)

    local function applyColors(sView, isChecked)
        pcall(function()
            local thumbColor = toJavaInt("FFFFFFFF")

            local trackColor =
                isChecked
                and toJavaInt("FF34C759")
                or toJavaInt("FF39393D")

            sView.getThumbDrawable().setColorFilter(
                thumbColor,
                PorterDuff.Mode.SRC_IN
            )

            sView.getTrackDrawable().setColorFilter(
                trackColor,
                PorterDuff.Mode.SRC_IN
            )

            iconView.setTextColor(
                isChecked
                and toJavaInt("FF34C759")
                or toJavaInt("FF007AFF")
            )
        end)
    end

    applyColors(sw, sw.isChecked())

    sw.setOnCheckedChangeListener(
        luajava.createProxy(
            "android.widget.CompoundButton$OnCheckedChangeListener",
            {
                onCheckedChanged = function(_, isChecked)

                    switchStates[key] = isChecked
                    applyColors(sw, isChecked)

                    if key == "sw_fps" and toggleFpsCounter then
                        showToast("APLICANDO: " .. label, isChecked)
                        toggleFpsCounter(isChecked)
                        return
                    end

                    if key == "sw_protection" and syncFlagSecure then
                        showToast("APLICANDO: " .. label, isChecked)
                        syncFlagSecure(lp, window, view)
                        return
                    end

                    local offsetAction = OFFSET.SWITCH[key]
                    local rangeAction = RANGES.SWITCH[key]

                    ------------------------------------------------
                    -- OFFSETS
                    ------------------------------------------------
                    if offsetAction then

                        showToast("APLICANDO: " .. label, isChecked)

                        thread(function()

                            local list =
                                offsetAction.lib
                                and {offsetAction}
                                or offsetAction

                            local successCount = 0
                            local totalCount = #list

                            for _, offData in ipairs(list) do

                                local finalValue = nil

                                if isChecked then

                                    finalValue = offData.valueOn

                                else

                                    local addrKey =
                                        offData.lib ..
                                        "_" ..
                                        string.format(
                                            "0x%X",
                                            offData.offset
                                        )

                                    if offData.valueOff then

                                        finalValue = offData.valueOff

                                    elseif type(originalValues[addrKey]) == "table" then

                                        local hex = ""

                                        for _, b in ipairs(originalValues[addrKey]) do
                                            if b < 0 then
                                                b = b + 256
                                            end

                                            hex = hex .. string.format("%02X", b)
                                        end

                                        finalValue = hex

                                    else

                                        finalValue =
                                            originalValues[addrKey]
                                            or offData.valueOn
                                    end
                                end

                                local ok = editMemory(
                                    offData.lib,
                                    offData.offset,
                                    offData.type,
                                    finalValue,
                                    label,
                                    isChecked
                                )

                                if ok then
                                    successCount = successCount + 1
                                end
                            end

                            if successCount > 0 then
                                showToast(
                                    label ..
                                    (
                                        isChecked
                                        and " ACTIVADO "
                                        or " DESACTIVADO "
                                    ) ..
                                    successCount ..
                                    "/" ..
                                    totalCount,
                                    isChecked
                                )
                            else
                                showToast(
                                    label .. " ERROR",
                                    false
                                )
                            end
                        end)

                        return
                    end

                    ------------------------------------------------
                    -- RANGES
                    ------------------------------------------------
                    if rangeAction then

                        showToast("APLICANDO: " .. label, isChecked)

                        thread(function()

                            local list = nil

                            if rangeAction.search then
                                list = {rangeAction}
                            else
                                list = rangeAction
                            end

                            local successCount = 0
                            local totalCount = #list

                            for _, data in ipairs(list) do

                                local ok = false

                                if isChecked then

                                    ok = editranges(
                                        data.search,
                                        data.limit,
                                        data.replace,
                                        data.ranges,
                                        data.type
                                    )

                                else

                                    local restoreValue =
                                        data.replaceOff
                                        or data.search

                                    ok = editranges(
                                        data.replace,
                                        data.limit,
                                        restoreValue,
                                        data.ranges,
                                        data.type
                                    )
                                end

                                if ok then
                                    successCount = successCount + 1
                                end
                            end

                            if successCount > 0 then

                                showToast(
                                    label ..
                                    (
                                        isChecked
                                        and " ACTIVADO "
                                        or " DESACTIVADO "
                                    ) ..
                                    successCount ..
                                    "/" ..
                                    totalCount,
                                    isChecked
                                )

                            else

                                showToast(
                                    label .. " NO ENCONTRADO",
                                    false
                                )
                            end
                        end)

                        return
                    end

                    ------------------------------------------------
                    -- NORMAL
                    ------------------------------------------------
                    showToast(
                        label ..
                        (
                            isChecked
                            and " ACTIVADO"
                            or " DESACTIVADO"
                        ),
                        isChecked
                    )
                end
            }
        )
    )

    container.addView(textContainer)
    container.addView(sw)

    parent.addView(container)

    local lp_res =
        luajava.new(
            LinearLayoutParams,
            -1,
            -2
        )

    lp_res.setMargins(
        0,
        0,
        0,
        dp2px(8)
    )

    container.setLayoutParams(lp_res)
end

local function addStyledSeekBar(parent, label, min, max, key)
    local container = luajava.new(LinearLayout, context)
    container.setOrientation(1)
    container.setPadding(dp2px(12), dp2px(10), dp2px(12), dp2px(10))
    container.setBackground(getGradientShape({toJavaInt("FF0A0A0A"), toJavaInt("FF111111")}, dp2px(10), toJavaInt("FF222222"), dp2px(1)))

    local header = luajava.new(LinearLayout, context)
    header.setOrientation(0)
    header.setGravity(16)

    local iconView = luajava.new(TextView, context)
    iconView.setTextColor(toJavaInt("FF007AFF"))
    iconView.setTextSize(14)
    iconView.setPadding(0, 0, dp2px(8), 0)
    local icon_tag = "sb_icon_" .. tostring(key)
    iconView.setTag(icon_tag)

    if FontAwesome then
        iconView.setTypeface(FontAwesome)
        local iconCode = FontIcon.seekbars[key] or FontIcon.menu['loading']
        iconView.setText(utf8.char(iconCode))
    end

    local txt = luajava.new(TextView, context)
    txt.setTextColor(toJavaInt("FFBBBBBB"))
    txt.setTextSize(10.5)
    txt.setText(label)
    txt.setLayoutParams(luajava.new(LinearLayoutParams, 0, -2, 1))

    local valTxt = luajava.new(TextView, context)
    valTxt.setTextColor(toJavaInt("FF34C759"))
    valTxt.setTextSize(10.5)
    valTxt.setText("OFF")
    local val_tag = "sb_val_" .. tostring(key)
    valTxt.setTag(val_tag)

    header.addView(iconView)
    header.addView(txt)
    header.addView(valTxt)
    container.addView(header)

    local fixed_min = min
    local fixed_range = max - min
    local last_color_state = -1

    local function applyIconColor(ratio)
        pcall(function()
            local icon = header.findViewWithTag(icon_tag)
            if not icon then return end

            if FontAwesome and tostring(icon.getText()) == "" then
                icon.setTypeface(FontAwesome)
                local iconCode = FontIcon.seekbars[key] or FontIcon.menu['loading']
                icon.setText(utf8.char(iconCode))
            end

            local new_state
            if ratio <= 0 then
                new_state = 0
            elseif ratio < 0.5 then
                new_state = 1
            else
                new_state = 2
            end

            if new_state ~= last_color_state then
                last_color_state = new_state
                if new_state == 0 then
                    icon.setTextColor(toJavaInt("FF007AFF"))
                elseif new_state == 1 then
                    icon.setTextColor(toJavaInt("FFFF9F0A"))
                else
                    icon.setTextColor(toJavaInt("FF34C759"))
                end
            end
        end)
    end

    local sb = luajava.new(SeekBar, context)
    sb.setMax(fixed_range)

    local initProgress = (switchStates[key] or min) - min
    sb.setProgress(initProgress)

    local initRatio = fixed_range > 0 and (initProgress * 1.0 / fixed_range) or 0
    applyIconColor(initRatio)

    pcall(function()
        sb.getThumb().setColorFilter(toJavaInt("FFFFFFFF"), PorterDuff.Mode.SRC_IN)
        sb.getProgressDrawable().setColorFilter(toJavaInt("FF34C759"), PorterDuff.Mode.SRC_IN)
    end)

    sb.setOnSeekBarChangeListener(luajava.createProxy("android.widget.SeekBar$OnSeekBarChangeListener", {
        onProgressChanged = function(_, progress, fromUser)
            local prog_num = math.floor(progress + 0)
            local actual_min = math.floor(fixed_min + 0)
            local actual_range = math.floor(fixed_range + 0)
            local actualValue = prog_num + actual_min

            local val = header.findViewWithTag(val_tag)
            if val then
                if prog_num <= 0 then
                    val.setText("OFF")
                    val.setTextColor(toJavaInt("FFFF3B30"))
                else
                    local display = string.format("%d", math.floor(actualValue))
                    val.setText(display)
                    val.setTextColor(toJavaInt("FF34C759"))
                end
            end

            local ratio = actual_range > 0 and (prog_num / actual_range) or 0
            applyIconColor(ratio)

            if fromUser then
                switchStates[key] = actualValue
                local action = OFFSET.SEKBAR[key]
                if action then
                    thread(function()
                        if action.offsets then
                            for _, off in ipairs(action.offsets) do
                                local valToApply = (actualValue == actual_min and action.valueOff) or actualValue
                                editMemory(action.lib, off, action.type, valToApply, label, true)
                            end
                        elseif action.offset then
                            local addrKey = action.lib .. "_" .. string.format("0x%X", action.offset)
                            local valToApply = (actualValue == actual_min and (action.valueOff or originalValues[addrKey])) or actualValue
                            editMemory(action.lib, action.offset, action.type, valToApply, label, true)
                        end
                    end)
                end
            end
        end,
        onStartTrackingTouch = function() end,
        onStopTrackingTouch = function(bar)
    local current = math.floor(bar.getProgress() + 0) + fixed_min
    if current == fixed_min then
        showToast(label .. " RESTABLECIDO", false)
    else
        showToast(label .. ": " .. string.format("%d", current), true)
    end
end
    }))

    container.addView(sb)
    parent.addView(container)

    local lp_res = luajava.new(LinearLayoutParams, -1, -2)
    lp_res.setMargins(0, 0, 0, dp2px(8))
    container.setLayoutParams(lp_res)
end

function updateTabContent(title)
    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            pcall(function()
                is_searching = false
                
                if menu_title then 
                    menu_title.setText(title)
                    applyIcons() 
                end

                if content_derecha then
                    content_derecha.removeAllViews()
                    
                    local data = { 
                        PLAYER = {
                                                        {name = "Speed Game", type = "seek", key = "sb_Game_Speed", min = 0, max = 150},
                            {name = "Infinite Board", type = "switch", key = "sw_laser_effect"}
                        }, 
                        POWER = {
                        {name = "Unlimited Jetpack", type = "switch", key = "sw_unlimit_ject"}
                        },
                        STORE = {
                        {name = "Free Shop", type = "switch", key = "sw_Free_Shop"},
                            {name = "Unlock All Skin", type = "switch", key = "sw_unlock_skin"},
                            {name = "Unlock All Board", type = "switch", key = "sw_unlock_board"}
                        },                        
                        SETTINGS = {
                            {name = "Ant Recording", type = "switch", key = "sw_protection"},
                            {name = "Show Fps", type = "switch", key = "sw_fps"}
                        }
                    }

                    local options = data[title] or {}

                    for _, item in ipairs(options) do
                        if item.type == "seek" then
                            addStyledSeekBar(content_derecha, item.name, item.min, item.max, item.key)
                        else
                            addStyledSwitch(content_derecha, item.name, item.key)
                        end
                    end
                    
                    content_derecha.invalidate()
                    content_derecha.requestLayout()
                end
            end)
        end
    }))
end

local function setupSearchContainer()
    local searchWrapper = luajava.new(LinearLayout, context)
    searchWrapper.setOrientation(0); searchWrapper.setGravity(16); searchWrapper.setPadding(dp2px(10), dp2px(2), dp2px(10), dp2px(2))
    searchWrapper.setBackground(getGradientShape({toJavaInt("FF0A0A0A")}, dp2px(10), toJavaInt("FF111111"), dp2px(1.2)))
    content_derecha.addView(searchWrapper, LinearLayoutParams(-1, -2))
    
    local searchIcon = luajava.new(TextView, context); searchIcon.setTextColor(0x66FFFFFF); searchIcon.setTextSize(14)
    if FontAwesome then searchIcon.setTypeface(FontAwesome); searchIcon.setText(utf8.char(FontIcon.menu['search'])) else searchIcon.setText("Q") end
    searchWrapper.addView(searchIcon)
    
    local searchBox = luajava.new(EditText, context)
    searchBox.setHint(" Buscar aplicaciones..."); searchBox.setHintTextColor(0x66FFFFFF); searchBox.setTextColor(-1); searchBox.setTextSize(10.5); searchBox.setBackgroundColor(0); searchBox.setSingleLine(true); searchBox.setLayoutParams(LinearLayoutParams(-1, -2))
    searchWrapper.addView(searchBox)
    
    local scrollList = luajava.new(ScrollView, context); content_derecha.addView(scrollList, LinearLayoutParams(-1, -1))
    resultList = luajava.new(LinearLayout, context); resultList.setOrientation(1); scrollList.addView(resultList)
    
    updateResults = function(filter)
        if not resultList or resultList.getParent() == nil then return end
        last_search_query = filter or ""
        resultList.removeAllViews()
        local f = last_search_query:lower()
        local pm = context.getPackageManager()
        
        thread(function()
            local count, added_packages = 0, {}
            for i=0, cached_apps.size()-1 do
                if not is_searching then break end
                local info = cached_apps.get(i)
                local pkg = tostring(info.packageName); local lab = tostring(pm.getApplicationLabel(info))
                
                if (f == "" or lab:lower():find(f) or pkg:lower():find(f)) and not added_packages[pkg] then
                    added_packages[pkg] = true
                    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
                        run = function()
                            if not resultList then return end
                            local btn = luajava.new(LinearLayout, context); btn.setOrientation(0); btn.setGravity(16); btn.setPadding(dp2px(10), dp2px(5), dp2px(10), dp2px(5)); btn.setTag(pkg)
                            local border = running_packages[pkg] and toJavaInt("FFFFFFFF") or toJavaInt("FF222222")
                            btn.setBackground(getGradientShape({toJavaInt("FF0A0A0A"), toJavaInt("FF111111")}, dp2px(10), border, running_packages[pkg] and dp2px(2.5) or dp2px(1)))
                            
                            local img = luajava.new(ImageView, context); pcall(function() img.setImageDrawable(pm.getApplicationIcon(info)) end)
                            btn.addView(img, LinearLayoutParams(dp2px(28), dp2px(28)))
                            
                            local txts = luajava.new(LinearLayout, context); txts.setOrientation(1); txts.setPadding(dp2px(10), 0, 0, 0)
                            local t1 = luajava.new(TextView, context); t1.setText(lab); t1.setTextColor(-1); t1.setTextSize(9)
                            local t2 = luajava.new(TextView, context); t2.setText(pkg); t2.setTextColor(toJavaInt("FFAAAAAA")); t2.setTextSize(7)
                            txts.addView(t1); txts.addView(t2); btn.addView(txts); btn.setClickable(true)
                            
                            btn.setOnClickListener(luajava.createProxy("android.view.View$OnClickListener", {
                                onClick = function() gg.setProcess(pkg); is_searching = false; updateTabContent("PLAYER"); lp.flags = 8 | 32; syncFlagSecure(lp, window, view) end
                            }))
                            
                            resultList.addView(btn); btn.getLayoutParams().setMargins(0, 0, 0, dp2px(8))
                        end
                    }))
                    count = count + 1; if count % 15 == 0 then gg.sleep(300) end
                end
            end
        end)
    end
    
    searchBox.addTextChangedListener(luajava.createProxy("android.text.TextWatcher", { 
        onTextChanged = function(s) last_search_query = tostring(s); updateResults(last_search_query) end, 
        afterTextChanged = function() end, beforeTextChanged = function() end 
    }))
end

local blue_pure, pure_white, red_grad = {toJavaInt("FF00008B"), toJavaInt("FF0000FF")}, 0xFFFFFFFF, {toJavaInt("FFED213A"), toJavaInt("FF93291E")}
local red_transparent = {toJavaInt("66FF0000"), toJavaInt("44FF0000")} 
local red_pure = toJavaInt("FFFF0000")

local function createTab(id, title)
    return {
        TextView,
        id = id,
        text = title,
        layout_width = "-1",
        layout_height = "35dp",
        gravity = "17",
        textColor = "-1",
        textSize = "9sp",
        textStyle = "bold",
        layout_marginBottom = "8dp",
        layout_marginHorizontal = "8dp",
        clickable = true,
        background = getAnimatedDrawable(blue_pure, dp2px(10), pure_white)
    }
end

local mainLayout = {
    FrameLayout; id="root"; layout_width="-1"; layout_height="-1"; background="#00000000"; 
    {
        FrameLayout; id="mFrame"; tag="main_frame"; layout_width="-1"; layout_height="-1"; layout_margin="4dp"; 
        {
            LinearLayout; id="main_content"; orientation="horizontal"; layout_width="-1"; layout_height="-1"; padding="10dp"; visibility=4;
            {
                LinearLayout; id="side_container"; orientation="vertical"; layout_width="-2"; layout_height="-1"; gravity="1";
                { ImageView; id="img_banner"; layout_width="55dp"; layout_height="55dp"; clickable=true; layout_gravity="1"; background="#00000000"; };
                {
                    LinearLayout; id="sidebar_content"; orientation="vertical"; layout_width="110dp"; layout_height="-1";
                    { TextView; id="shimmer_main_title", text="LITDARKRX"; textColor="-1"; textSize="11sp"; textStyle="bold"; layout_width="-1"; layout_marginTop="6dp"; gravity="1"; };
                    { View; layout_width="-1"; layout_height="2dp"; background=getGradientShape({toJavaInt("FF0000FF"), 0}, 0); layout_marginTop="8dp"; layout_marginBottom="12dp"; };
                    {
                        ScrollView; layout_width="-1"; layout_height="0dp"; layout_weight="1"; fillViewport=true;
                        {
                            LinearLayout; orientation="vertical"; layout_width="-1"; layout_height="-2";
    createTab("tab_player", "PLAYER"),
    createTab("tab_power", "POWER"),
    createTab("tab_store", "STORE"),
                        };
                    };
                    { TextView; id="btn_exit", text="CLOSE", textColor="-1"; textSize="9sp"; textStyle="bold"; gravity="17"; layout_width="-1"; layout_height="30dp"; layout_marginBottom="10dp"; layout_marginHorizontal="12dp"; clickable=true; background=getGradientShape(red_transparent, dp2px(12), red_pure, dp2px(1.5)); };
                };
            };
            { LinearLayout; id="separator_container"; layout_width="0dp"; layout_weight="0.05"; layout_height="-1"; gravity="17"; { View; id="separator_line"; layout_width="1dp"; layout_height="-1"; background="#44FFFFFF"; }; };
            {
                LinearLayout; id="container_right"; orientation="vertical"; layout_width="0dp"; layout_weight="1"; layout_height="-1"; layout_marginLeft="5dp";
                {
                    LinearLayout; layout_width="-1"; layout_height="-2"; orientation="vertical";
                    { 
                        LinearLayout; layout_width="-1"; layout_height="35dp"; orientation="horizontal"; gravity="16"; 
                        { ImageView; id="app_icon"; layout_width="25dp"; layout_height="25dp"; layout_marginLeft="5dp"; clickable=true; background="#00000000"; };
                        { TextView; id="menu_title"; text="PLAYER"; textColor="-1"; textSize="13sp"; textStyle="bold"; layout_weight="1"; gravity="17"; }; 
                        { TextView; id="btn_settings_nut"; text="⚙"; textColor="-1"; textSize="22sp"; clickable=true; paddingRight="10dp"; }; 
                    };
                    { View; layout_width="-1"; layout_height="1dp"; background="#66FFFFFF"; layout_marginBottom="5dp"; };
                };
                { FrameLayout; id="matrix_container"; layout_width="-1"; layout_height="25dp"; clipChildren=true; { TextView; id="fixed_info", text=" [ Created By LitDarKrx | ©Copyright 2026 ] ", textColor="#FFFFFF", textSize="11sp", textStyle="bold", gravity="16", layout_width="-2", layout_height="-1", singleLine="true", ellipsize="none" }; };
                { LinearLayout; orientation="vertical"; id="content_derecha"; layout_width="-1"; layout_height="-1"; padding="10dp"; };
            };
        };
        {
            FrameLayout; id="global_splash"; layout_width="-1"; layout_height="-1";
            {
                LinearLayout; orientation="vertical"; gravity="17"; layout_width="-1"; layout_height="-1";
                { TextView; id="splash_icon"; textSize="40sp"; textColor="-1"; gravity="17"; };
                { TextView; id="splash_status"; text="LITDARKRX SYSTEM"; textSize="11sp"; textColor="0xCCFFFFFF"; layout_marginTop="15dp"; textStyle="bold"; };
            };
        };
    };
}

invoke = function()
    pcall(function()
        view = loadlayout(mainLayout); updateTabContent("PLAYER")
        lp = luajava.new(LayoutParams)
        lp.type = (Build.VERSION.SDK_INT >= 26) and 2038 or 2002
        lp.format = -3
        lp.gravity = 17 
        lp.x = 0
        lp.y = 0
        lp.flags = 8 | 32
        applyResponsiveMenuSize(lp)
        lastScreenW, lastScreenH = getScreenSize()
startRotationFix()
        
        thread(function()
            while menu_active do
                pcall(function()
                    local am = context.getSystemService("activity"); local procs = am.getRunningAppProcesses(); local newList = {}; local ggTarget = gg.getTargetPackage()
                    if ggTarget and ggTarget ~= "" then newList[ggTarget] = true end
                    if procs then for i=0, procs.size()-1 do local pi = procs.get(i); if pi.pkgList then for j=1, #pi.pkgList do newList[tostring(pi.pkgList[j])] = true end end end end
                    running_packages = newList
                    local mainPkg = ggTarget ~= "" and ggTarget or "com.android.settings"
                    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { 
                        run = function() 
                            if app_icon then app_icon.setImageDrawable(context.getPackageManager().getApplicationIcon(mainPkg)) end
                            if is_searching and resultList then
                                for i = 0, resultList.getChildCount() - 1 do
                                    local child = resultList.getChildAt(i)
                                    if child then
                                        local pkg = tostring(child.getTag()) 
                                        local border = running_packages[pkg] and toJavaInt("FFFFFFFF") or toJavaInt("FF222222")
                                        child.setBackground(getGradientShape({toJavaInt("FF0A0A0A"), toJavaInt("FF111111")}, dp2px(10), border, running_packages[pkg] and dp2px(2.5) or dp2px(1)))
                                    end
                                end
                            end
                        end 
                    }))
                end)
                gg.sleep(2000)
            end
        end)

        app_icon.onClick = function() 
            pcall(function()
                menu_title.setText("SELECT PROCCES"); is_searching = true; lp.flags = 32; syncFlagSecure(lp, window, view)
                activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
                    run = function()
                        content_derecha.removeAllViews()
                        local splashRoot = luajava.new(FrameLayout, context); local rootBg = luajava.new(GradientDrawable); rootBg.setColor(toJavaInt("DD0A0A0A")); rootBg.setCornerRadius(dp2px(12)); rootBg.setStroke(dp2px(1), toJavaInt("30FFFFFF")); splashRoot.setBackground(rootBg)
                        content_derecha.addView(splashRoot, LinearLayoutParams(-1, -1))
                        
                        local particleLayer = luajava.new(FrameLayout, context); splashRoot.addView(particleLayer, FrameLayoutParams(-1, -1))
                        
                        thread(function()
                            gg.sleep(100); activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { run = function()
                                for i = 1, 8 do
                                    local dot = luajava.new(View, context); dot.setBackground(getGradientShape({toJavaInt("60FFFFFF"), 0}, dp2px(2)))
                                    local size = dp2px(math.random(2, 4)); local p = FrameLayoutParams(size, size); p.gravity = 17; p.leftMargin, p.topMargin = dp2px(math.random(-100, 100)), dp2px(math.random(-80, 80)); particleLayer.addView(dot, p)
                                    ObjectAnimator.ofFloat(dot, "alpha", 0.1, 0.7).setDuration(math.random(1000, 2000)).setRepeatCount(-1).setRepeatMode(2).start()
                                    ObjectAnimator.ofFloat(dot, "scaleX", 0.5, 1.3).setDuration(math.random(1500, 2500)).setRepeatCount(-1).setRepeatMode(2).start()
                                end
                            end }))
                        end)

                        local centerUI = luajava.new(LinearLayout, context); centerUI.setOrientation(1); centerUI.setGravity(17); splashRoot.addView(centerUI, FrameLayoutParams(-1, -1))
                        local loadIcon = luajava.new(TextView, context); loadIcon.setTextSize(26); loadIcon.setTextColor(pure_white); loadIcon.setGravity(17)
                        if FontAwesome then loadIcon.setTypeface(FontAwesome); loadIcon.setText(getIcon(FontIcon.menu['circle-notch'])) end
                        centerUI.addView(loadIcon, LinearLayoutParams(-2, -2))
                        
                        ObjectAnimator.ofFloat(loadIcon, "rotation", 0, 360).setDuration(1000).setRepeatCount(-1).setInterpolator(LinearInterpolator()).start()
                        
                        local loadTxt = luajava.new(TextView, context); if FontAwesome then loadTxt.setTypeface(FontAwesome) end; loadTxt.setText("Starting list of processes..."); loadTxt.setTextColor(toJavaInt("B0FFFFFF")); loadTxt.setTextSize(10); loadTxt.setGravity(17); loadTxt.setPadding(0, dp2px(15), 0, 0); centerUI.addView(loadTxt, LinearLayoutParams(-2, -2))
                        
                        ObjectAnimator.ofFloat(loadTxt, "alpha", 0.5, 1).setDuration(800).setRepeatCount(-1).setRepeatMode(2).start()
                        ObjectAnimator.ofFloat(centerUI, "scaleX", 1, 1.03).setDuration(1500).setRepeatCount(-1).setRepeatMode(2).setInterpolator(AccelerateDecelerateInterpolator()).start()
                        ObjectAnimator.ofFloat(centerUI, "scaleY", 1, 1.03).setDuration(1500).setRepeatCount(-1).setRepeatMode(2).setInterpolator(AccelerateDecelerateInterpolator()).start()
                        
                        thread(function()
                            if not first_load_done then cached_apps = context.getPackageManager().getInstalledApplications(0); gg.sleep(1500); first_load_done = true else loadTxt.setText("Looking for new processes..."); gg.sleep(800) end
                            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { run = function() if not is_searching then return end; content_derecha.removeAllViews(); setupSearchContainer(); updateResults("") end }))
                        end)
                    end
                }))
            end)
        end

        thread(function()
            local retryButton
            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { run = function() 
                if global_splash then
                    local splashBg = luajava.new(GradientDrawable); splashBg.setColor(toJavaInt("FB0A0A0A")); splashBg.setCornerRadius(dp2px(18)); splashBg.setStroke(dp2px(1.2), toJavaInt("22FFFFFF")); global_splash.setBackground(splashBg)
                    local barTrack = luajava.new(View, context); local trackShape = luajava.new(GradientDrawable); trackShape.setColor(toJavaInt("15FFFFFF")); trackShape.setCornerRadius(dp2px(2)); barTrack.setBackground(trackShape); global_splash.addView(barTrack, FrameLayoutParams(dp2px(220), dp2px(4), 17))
                    progressBar = luajava.new(View, context); local progressShape = luajava.new(GradientDrawable); progressShape.setColor(toJavaInt("FFFFFFFF")); progressShape.setCornerRadius(dp2px(2)); progressBar.setBackground(progressShape); global_splash.addView(progressBar, FrameLayoutParams(0, dp2px(4), 17))
                    
                    retryButton = luajava.new(Button, context); retryButton.setText("TRY AGAIN"); retryButton.setVisibility(8); retryButton.setTextColor(toJavaInt("FFFFFFFF"))
                    local btnBg = luajava.new(GradientDrawable); btnBg.setColor(toJavaInt("33FF4444")); btnBg.setCornerRadius(dp2px(10)); btnBg.setStroke(dp2px(1), toJavaInt("66FF4444")); retryButton.setBackground(btnBg)
                    global_splash.addView(retryButton, FrameLayoutParams(dp2px(140), dp2px(38), 17))
                    retryButton.setOnClickListener(luajava.createProxy("android.view.View$OnClickListener", { onClick = function(v) v.setVisibility(8); if splash_status then splash_status.setText("RECONNECTING...") end; load_assets_direct() end }))
                end
            end }))
            
            local progress = 0
            while menu_active do
                local done = assets_loaded.image and assets_loaded.font; local err = assets_error.image or assets_error.font
                if not done and not err then if progress < 98 then progress = progress + 0.8 end elseif done then progress = 100 end
                activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { run = function() 
                    if progressBar then progressBar.getLayoutParams().width = dp2px((progress / 100) * 220); progressBar.requestLayout() end
                    if splash_status then if done then splash_status.setText("Starting UI") elseif err then splash_status.setText("Connection error"); if retryButton then retryButton.setVisibility(0) end else splash_status.setText("Downloading Resources: " .. math.floor(progress) .. "%") end end
                end }))
                if done then 
                    pcall(function() 
                        if Point and Point.f then
                            gg.setVisible(false)
                            Point.f() 
                        end 
                    end)
                    break 
                end; gg.sleep(80)
            end
            gg.sleep(800)
            
            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { run = function() 
                if global_splash then 
                    ObjectAnimator.ofFloat(global_splash, "alpha", 1, 0).setDuration(500).start()
                    thread(function()
                        gg.sleep(500); activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { run = function()
                            global_splash.setVisibility(8); global_splash.removeAllViews() 
                            if main_content then main_content.setVisibility(0); main_content.setAlpha(0); ObjectAnimator.ofFloat(main_content, "alpha", 0, 1).setDuration(500).start() end
                            addAnimatedBorder(root)
                        end }))
                    end)
                end
            end }))
        end)
        
        loadLogo(img_banner)

        neonMarqueeFlow(fixed_info); neonFlowPro(matrix_container)
        
        local th = luajava.createProxy("android.view.View$OnTouchListener", {
    onTouch = function(v, e)
        local action = e.getAction()

        if action == MotionEvent.ACTION_DOWN then
            sX = e.getRawX()
            sY = e.getRawY()
            oX = lp.x
            oY = lp.y
            mov = false
            return true

        elseif action == MotionEvent.ACTION_MOVE then
            local dX = e.getRawX() - sX
            local dY = e.getRawY() - sY

            if math.abs(dX) > 6 or math.abs(dY) > 6 then
                mov = true
                lp.x = math.floor(oX + dX)
                lp.y = math.floor(oY + dY)

                pcall(function()
                    window.updateViewLayout(view, lp)
                end)
            end
            return true

        elseif action == MotionEvent.ACTION_UP then
            if not mov then
                if v == img_banner then
                    setMenuMinimized(not is_minimized)
                elseif v == btn_settings_nut then
                    btn_settings_nut.performClick()
                elseif v == app_icon then
                    app_icon.performClick()
                end
            end
            return true
        end

        return false
    end
})
        
        root.setOnTouchListener(th); img_banner.setOnTouchListener(th); btn_settings_nut.setOnTouchListener(th); app_icon.setOnTouchListener(th)
        
        tab_player.onClick = function() updateTabContent("PLAYER"); lp.flags = 8 | 32; syncFlagSecure(lp, window, view) end
        tab_power.onClick = function() updateTabContent("POWER"); lp.flags = 8 | 32; syncFlagSecure(lp, window, view) end
        tab_store.onClick = function() updateTabContent("STORE"); lp.flags = 8 | 32; syncFlagSecure(lp, window, view) end
        
        btn_exit.onClick = function()
            menu_active = false
            show_fps_enabled = false
            
            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
                run = function()
                    pcall(function()
                        if view then view.clearAnimation() end
                        
                        if fps_view then 
                            window.removeView(fps_view)
                            fps_view = nil 
                        end
                        if view then 
                            window.removeView(view)
                            view = nil 
                        end
                        
                        Lock.unUi()
                    end)
                end
            }))

            thread(function()
                gg.sleep(300)
                pcall(function() gg.setVisible(true) end)
                gg.sleep(100)
                pcall(function() os.exit() end)
            end)
        end

        btn_settings_nut.onClick = function()
            pcall(function() 
                content_derecha.removeAllViews()
                menu_title.setText("SETTINGS")
                applyIcons()
                        
                addStyledSwitch(content_derecha, "Ant Recording", "sw_protection")
                addStyledSwitch(content_derecha, "Show Fps", "sw_fps")
                
                local infoText = luajava.new(TextView, context)
                infoText.setText("Created By LitDarKrx\nDeveloper And Designer\n2022")
                infoText.setTextColor(toJavaInt("88FFFFFF")) 
                infoText.setTextSize(9)
                infoText.setGravity(17) 
                infoText.setPadding(0, dp2px(20), 0, dp2px(10))
                infoText.setTypeface(Typeface.create("sans-serif-light", Typeface.BOLD))
                
                local lp_info = luajava.new(LinearLayoutParams, -1, -2)
                infoText.setLayoutParams(lp_info)
                
                content_derecha.addView(infoText)
                lp.flags = 8 | 32; syncFlagSecure(lp, window, view)
                content_derecha.requestLayout()
            end)
        end
        
        window.addView(view, lp); load_assets_direct()
    end)
end

local function protected_main()
    local status, err = xpcall(function()
        invoke()
    end, function(e)
        local trace = tostring(e)
        pcall(function()
            if debug and debug.traceback then
                trace = debug.traceback(tostring(e), 2)
            end
        end)
        return trace
    end)

    if not status then
        write_log(err)
        pcall(function() gg.toast("CRASH GUARDADO EN: " .. CRASH_LOG_PATH) end)
        pcall(function() gg.setVisible(true) end)

        activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
            run = function()
                pcall(function()
                    if fps_view then window.removeView(fps_view) end
                    if view then window.removeView(view) end
                    Lock.unUi()
                end)
            end
        }))
        os.exit()
    end
end


Lock.Ui(protected_main)