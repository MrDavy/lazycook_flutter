class LazyUri {
  ///user
  ///注册
  static const String REGISTER = "user/v1/register.do";

  ///登录
  static const String LOGIN = "user/v1/login.do";

  ///登出
  static const String LOGOUT = "user/v1/logout.do";

  ///更新头像
  static const String AVATAR_UPDATE = "user/v1/updateAvatar.do";

  ///更新头像
  static const String NICKNAME_UPDATE = "user/v1/updateNickName.do";

  ///找回密码
  static const String RESET_PWD = "user/v1/resetPwd.do";

  ///获取验证码
  static const String AUTH_CODE = "user/v1/sendCode.do";

  ///校验验证码
  static const String CODE_VALIDATE = "user/v1/codeValidate.do";

  ///home
  ///首页基本信息
  static const String HOME_BASIC_INFO = "recipe/home/v1/homeBasicInfo.do";

  ///首页广告
  static const String HOME_BANNERS = "recipe/home/v1/homeBanners.do";

  ///首页分类
  static const String HOME_CATEGORIES = "recipe/home/v1/homeCategories.do";

  ///推荐菜品
  static const String RECOMMEND_DISHES = "recipe/home/v1/recommendDishes.do";

  ///菜品
  ///菜品详情
  static const String DISH_DETAIL = "recipe/dish/v1/recipeDetail.do";

  ///菜品大类
  static const String CATEGORIES = "recipe/dish/v1/recipeParentCategories.do";

  ///菜品小类
  static const String CHILD_CATEGORIES =
      "recipe/dish/v1/recipeChildCategories.do";

  ///person
  ///收藏/取消收藏
  static const String COLLECT = "recipe/dish/v1/collect.do";

  ///收藏列表
  static const String COLLECTION_LIST = "recipe/dish/v1/getCollectedRecipes.do";

  ///作品列表
  static const String WORK_LIST = "recipe/dish/v1/works.do";

  ///删除作品
  static const String DELETE_WORK = "recipe/dish/v1/delWorks.do";

  ///新建菜品
  static const String NEW_WORK = "recipe/dish/v1/addRecipe.do";

  ///系统
  ///意见反馈
  static const String FEEDBACK = "system/feedback/v1/addFeedback.do";

  ///版本检查
  static const String VERSION = "system/app-version/v1/checkVersion.do";

  ///图片上传
  static const String IMG_UPLOAD = "system/file/v1/uploadImage.do";

  ///搜索
  static const String SEARCH_DISHES = "search/dish/v1/recipeList.do";

  ///搜索历史
  static const String RECIPE_SEARCH_HISTORY =
      "recipe/dish/v1/getRecipeSearchHistory.do";

  ///删除搜索历史
  static const String DELETE_SEARCH_HISTORY =
      "recipe/dish/v1/delRecipeSearchHistory.do";
}
