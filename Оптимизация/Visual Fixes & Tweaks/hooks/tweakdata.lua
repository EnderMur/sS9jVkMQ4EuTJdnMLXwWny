Hooks:Add("LocalizationManagerPostInit", "modify_color_grading", function(loc)
    if tweak_data and tweak_data.color_grading then
        for i, grade in ipairs(tweak_data.color_grading) do
            if grade.text_id == "menu_color_default" then
                grade.value = "color_payday"
                break
            end
        end
    end
    
    -- Add custom localization
    LocalizationManager:add_localized_strings({
        ["menu_color_default"] = "PAYDAY +"
    })
end)