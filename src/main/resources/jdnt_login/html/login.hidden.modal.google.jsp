<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="ui" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<%--@elvariable id="currentUser" type="org.jahia.services.usermanager.JahiaUser"--%>
<%--@elvariable id="currentAliasUser" type="org.jahia.services.usermanager.JahiaUser"--%>

<c:set var="googleNode"/>
<c:forEach var="node" items="${jcr:getDescendantNodes(renderContext.site, 'joant:googleOAuthSettings')}">
    <c:set var="googleNode" value="${node}"/>
</c:forEach>
<p class="fieldset">
<c:if test="${(not renderContext.liveMode and googleNode eq '') or (googleNode ne '' and not googleNode.properties.isActivate.boolean)}">
    <div style="color: red;">
        <fmt:message key="socialButton.googleButton.error.connectorNotConfigured"/>
    </div>
</c:if>

<c:if test="${googleNode ne '' and googleNode.properties.isActivate.boolean and (not renderContext.loggedIn or renderContext.editMode)}">
    <template:addResources>
        <script>
            function connectToGoogle${fn:replace(currentNode.identifier, '-', '')}() {
                var popup = window.open('', "Google Authorization", "menubar=no,status=no,scrollbars=no,width=1145,height=725,modal=yes,alwaysRaised=yes");
                var xhr = new XMLHttpRequest();
                xhr.open('GET', '<c:url value="${url.base}${renderContext.site.home.path}"/>.connectToGoogleAction.do');
                xhr.setRequestHeader('Accept', 'application/json;');
                xhr.send();

                xhr.onreadystatechange = function () {
                    if (xhr.readyState != 4 || xhr.status != 200) return;
                    var json = JSON.parse(xhr.responseText);
                    popup.location.href = json.authorizationUrl;
                    window.addEventListener('message', function (event) {
                        if (event.data.authenticationIsDone) {
                            setTimeout(function () {
                                popup.close();
                                if (event.data.isAuthenticate) {
                                    window.location.search = 'site=${renderContext.site.siteKey}';
                                }
                            }, 3000);
                        }
                    });
                };
            }
        </script>
    </template:addResources>

    <a href="#" style="color: transparent;"
       onclick="connectToGoogle${fn:replace(currentNode.identifier, '-', '')}();return false;"
       <c:if test="${renderContext.editMode}">disabled</c:if> >
        <img class="social-login-logo google-social-logo" src="<c:url value="${url.currentModule}/img/btn_google_signin_dark_normal_web@2x.png"/>" alt="" border="0"/>
    </a>

</c:if>
</p>
