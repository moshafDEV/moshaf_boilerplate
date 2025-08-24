import 'package:ProjectName/core/config/di_module/init_config.dart';

class gtmService {
  pageView(String pageName) {
    gtm.push('page_view', parameters: {'name': pageName});
  }
}
